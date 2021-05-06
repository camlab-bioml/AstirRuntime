import pandas as pd
import numpy as np
from anndata import AnnData

configfile: "runtime-analysis-config.yml"

input_data = "../imc-2020/output/squirrel/sces/"
markers_path = "../imc-2020/markers/"
output_path = "output/" + config['version'] + "/"


no_of_cells = [1000, 2000, 3000]
marker_options = ['all_markers', 'specified_markers']
phenograph_sizes = [10, 20, 30]
FlowSOM_sizes = [4, 6, 8]
acdc_options = [ 'absent', 'no-consider']

runtime_output = {
    'astir_runtime': expand(output_path + "runtime/astir-{cells}-cells.csv", cells = no_of_cells),
    'phenograph_runtime': expand(output_path + "runtime/phenograph-{cells}-cells-{markers}-k-{k}.csv", 
                               cells = no_of_cells, markers = marker_options, k = phenograph_sizes),
    'FlowSOM_runtime': expand(output_path + "runtime/FlowSOM-{cells}-cells-{markers}-k-{k}.csv", 
                               cells = no_of_cells, markers = marker_options, k = FlowSOM_sizes),
    'ClusterX_runtime': expand(output_path + "runtime/ClusterX-{cells}-cells-{markers}.csv", 
                               cells = no_of_cells, markers = marker_options),
    'acdc': expand(output_path + 'runtime/ACDC-{cells}-cells-{options}.csv', cells = no_of_cells, options = acdc_options),
    'viz': output_path + "figures/runtime.pdf"
}

print(runtime_output['acdc'])

rule all:
    input:
        subsets = expand(output_path + "anndata/basel-{cells}-cells-subset.h5ad", cells = no_of_cells),
        astir_assignments = expand(output_path + "astir_assignments/basel_astir_assignments-{cells}-cells.csv", cells = no_of_cells),
        fig = expand(output_path + "astir_assignments/basel_astir_assignment-{cells}-cells_loss.png", cells = no_of_cells),
        diagnostics = expand(output_path + "astir_assignments/basel_astir_assignment-{cells}-cells_diagnostics.csv", cells = no_of_cells),
        runtime = runtime_output['astir_runtime'],
        phenograph = runtime_output['phenograph_runtime'],
        FlowSOM = runtime_output['FlowSOM_runtime'],
        ClusterX = runtime_output['ClusterX_runtime'],
        acdc = runtime_output['acdc'],
        viz = runtime_output['viz']


rule create_ad_subsets:
    input:
        basel = input_data + "basel_sce.rds"
    output:
        h5ad = output_path + "anndata/basel-{cells}-cells-subset.h5ad",
        sce = output_path + "sces/basel-{cells}-cells-subset.rds"
    script:
        "scripts/create_subsets.R"


rule astir:
    input:
        anndata = output_path + "anndata/basel-{cells}-cells-subset.h5ad",
        markers = markers_path + "jackson-2020-markers-v4.yml"
    params:
        max_epochs = 1000,
        learning_rate = 2e-3,
        n_init_epochs = 3
    output:
        csv = output_path + "astir_assignments/basel_astir_assignments-{cells}-cells.csv",
        fig = output_path + "astir_assignments/basel_astir_assignment-{cells}-cells_loss.png",
        diagnostics = output_path + "astir_assignments/basel_astir_assignment-{cells}-cells_diagnostics.csv",
        runtime = output_path + "runtime/astir-{cells}-cells.csv"
    run:
        # Import
        from astir.data import from_anndata_yaml
        from datetime import datetime

        # Start timing
        start = datetime.now()

        # Create astir object
        ast = from_anndata_yaml(input.anndata, input.markers)

        N = ast.get_type_dataset().get_exprs_df().shape[0]
        batch_size = int(N/100)

        ast.fit_type(max_epochs = int(params.max_epochs), 
                    batch_size = batch_size, 
                    learning_rate = float(params.learning_rate),
                    n_init_epochs=int(params.n_init_epochs))

        time = datetime.now() - start

        # Save runtime results
        time_df = pd.DataFrame({'time': [time.total_seconds()],
                                'method': ['Astir'],
                                'cells': [N]})
        time_df.to_csv(output.runtime, index = False)
        
        # Save assignments
        ast.get_celltype_probabilities().to_csv(output.csv)

        # Run diagnostics
        ast.diagnostics_celltype().to_csv(output.diagnostics)

        # plot loss
        import matplotlib.pyplot as plt
        plt.figure(figsize=(5,4))
        plt.plot(np.arange(len(ast.get_type_losses())), ast.get_type_losses())
        plt.ylabel("Loss")
        plt.xlabel("Epoch")
        plt.tight_layout()
        plt.savefig(output.fig, dpi=300)


rule phenograph:
    input:
        sce = output_path + "sces/basel-{cells}-cells-subset.rds",
        markers = markers_path + "jackson-2020-markers-v4.yml"
    output:
        runtime = output_path + "runtime/phenograph-{cells}-cells-{markers}-k-{k}.csv"
    script:
        "scripts/phenograph.R"


rule FlowSOM:
    input:
        sce = output_path + "sces/basel-{cells}-cells-subset.rds",
        markers = markers_path + "jackson-2020-markers-v4.yml"
    output:
        runtime = output_path + "runtime/FlowSOM-{cells}-cells-{markers}-k-{k}.csv"
    script:
        "scripts/FlowSOM.R"


rule ClusterX:
    input:
        sce = output_path + "sces/basel-{cells}-cells-subset.rds",
        markers = markers_path + "jackson-2020-markers-v4.yml"
    output:
        runtime = output_path + "runtime/ClusterX-{cells}-cells-{markers}.csv"
    script:
        "scripts/ClusterX.R"


rule acdc:
    input:
        anndata = output_path + "anndata/basel-{cells}-cells-subset.h5ad",
        markers = markers_path + "jackson-2020-markers-v4.yml" 
    output:
        csv = output_path + 'runtime/ACDC-{cells}-cells-{options}.csv'
    shell:
        "python scripts/acdc_runtime.py "
        "--input_h5ad {input.anndata} "
        "--input_yaml {input.markers} "
        "--output_assignments {output.csv} "
        "--method {wildcards.options} "
        "--cohort {wildcards.cells} "





rule viz_runtime:
    input:
        astir = runtime_output['astir_runtime'],
        phenograph = runtime_output['phenograph_runtime'],
        FlowSOM = runtime_output['FlowSOM_runtime'],
        ClusterX = runtime_output['ClusterX_runtime']
    output:
        fig = runtime_output['viz']
    script:
        "scripts/viz.R"
