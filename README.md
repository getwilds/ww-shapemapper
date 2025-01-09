# ww-shapemapper
[![Project Status: Experimental – Useable, some support, not open to feedback, unstable API.](https://getwilds.org/badges/badges/experimental.svg)](https://getwilds.org/badges/#experimental)

A WDL workflow for running ShapeMapper RNA structure probing analysis in parallel across multiple samples.

## Prerequisites

- Cromwell or other WDL-compatible workflow executor
- Docker installation (if using containerized execution)
- ShapeMapper Docker image
- Input FASTQ files from SHAPE-MaP experiments
- Reference sequences in FASTA format

## Workflow Overview

This workflow enables parallel processing of multiple RNA samples through the ShapeMapper pipeline. For each sample, it:
1. Processes paired-end reads from modified and untreated conditions
2. Calculates SHAPE reactivity profiles
3. Generates quality control metrics
4. Organizes outputs in sample-specific directories

## Input Description

The workflow takes a structured input format using WDL structs. Each sample requires:

```wdl
struct SampleInfo {
    String name           # Sample identifier
    File target_fa       # Reference sequence in FASTA format
    File modified_r1     # Forward reads from modified sample
    File modified_r2     # Reverse reads from modified sample
    File untreated_r1    # Forward reads from untreated sample
    File untreated_r2    # Reverse reads from untreated sample
}
```

### Optional Parameters

- `primers_fa`: FASTA file containing primer sequences
- `min_depth`: Minimum read depth for reporting reactivity (default: 5000)
- `is_amplicon`: Boolean flag for amplicon sequencing data (default: false)

### Runtime Parameters (per task)

- `memory_gb`: Memory allocation in GB (default: 16)
- `cpu`: Number of CPU cores (default: 4)

## Usage

1. Create an inputs JSON file:

```json
{
  "ShapeMapperAnalysis.samples": [
    {
      "name": "sample1",
      "target_fa": "sample1.fa",
      "modified_r1": "sample1_mod_R1.fq",
      "modified_r2": "sample1_mod_R2.fq",
      "untreated_r1": "sample1_unmod_R1.fq",
      "untreated_r2": "sample1_unmod_R2.fq"
    }
  ],
  "ShapeMapperAnalysis.primers_fa": "primers.fa",
  "ShapeMapperAnalysis.min_depth": 1000,
  "ShapeMapperAnalysis.is_amplicon": true
}
```

2. Run the workflow:

```bash
# Using Cromwell
java -jar cromwell.jar run shapemapper.wdl -i inputs.json

# Using miniwdl
miniwdl run shapemapper.wdl -i inputs.json
```

## Outputs

For each sample, the workflow produces:

- `shape_file`: SHAPE reactivity profile (.shape format)
- `log_file`: Execution logs and quality metrics
- `output_dir`: Directory containing all output files including:
  - Processed alignment files
  - Quality control plots
  - Summary statistics
  - Intermediate files

## Docker Requirements

The workflow uses the [`shapemapper`](https://github.com/getwilds/wilds-docker-library/blob/main/shapemapper/Dockerfile_2.3) Docker image from the [WILDS Docker Library](https://github.com/getwilds/wilds-docker-library), specifically `getwilds/shapemapper:2.3`. If you would like to provide your own, update the `docker` runtime parameter in the WDL with your specific image:

```wdl
runtime {
    docker: "your-registry/shapemapper:version"
}
```

## Notes

- Input FASTQ files should be quality-checked and adapter-trimmed if necessary
- Ensure sufficient disk space for intermediate files
- Memory and CPU requirements may need adjustment based on RNA length and sequencing depth
- All file paths in the inputs JSON should be absolute or relative to the workflow execution directory

## Troubleshooting

Common issues and solutions:

1. **Insufficient memory**: Increase `memory_gb` for longer RNA sequences
2. **Disk space errors**: Adjust `disk_size` based on input file sizes
3. **Missing outputs**: Check log files for execution errors
4. **Docker errors**: Ensure the specified Docker image is accessible

## Citation

If you use this workflow, please cite:

- ShapeMapper: Busan S, Weeks KM. Accurate detection of chemical modifications in RNA by mutational profiling (MaP) with ShapeMapper 2. RNA. 2018, 24(2):143-148.
