version 1.0

struct SampleInfo {
    String name
    File target_fa
    File modified_r1
    File modified_r2
    File untreated_r1
    File untreated_r2
}

workflow ShapeMapperAnalysis {
    input {
        Array[SampleInfo] samples
        File? primers_fa
        Int min_depth = 5000
        Boolean is_amplicon = false
    }

    scatter (sample in samples) {
        call RunShapeMapper {
            input:
                sample_name = sample.name,
                target_fa = sample.target_fa,
                modified_r1 = sample.modified_r1,
                modified_r2 = sample.modified_r2,
                untreated_r1 = sample.untreated_r1,
                untreated_r2 = sample.untreated_r2,
                primers_fa = primers_fa,
                min_depth = min_depth,
                is_amplicon = is_amplicon
        }
    }

    output {
        Array[File] shape_files = RunShapeMapper.shape_file
        Array[File] log_files = RunShapeMapper.log_file
    }
}

task RunShapeMapper {
    input {
        String sample_name
        File target_fa
        File modified_r1
        File modified_r2
        File untreated_r1
        File untreated_r2
        File? primers_fa
        Int min_depth
        Boolean is_amplicon
        # Runtime parameters
        Int memory_gb = 16
        Int cpu = 4
    }

    command <<<
        set -e
        
        # Create output directory
        mkdir ~{sample_name}_output

        # Build ShapeMapper command
        cmd="shapemapper \
            --name ~{sample_name} \
            --target ~{target_fa} \
            --modified \"--nmod ~{modified_r1} ~{modified_r2}\" \
            --untreated \"--unmod ~{untreated_r1} ~{untreated_r2}\" \
            --min-depth ~{min_depth} \
            --out ~{sample_name}_output"

        # Add optional arguments
        ~{if is_amplicon then "cmd+=' --amplicon'" else ""}
        ~{if defined(primers_fa) then "cmd+=' --primers ${primers_fa}'" else ""}

        # Run ShapeMapper
        eval $cmd
    >>>

    output {
        File shape_file = "~{sample_name}_output/~{sample_name}.shape"
        File log_file = "~{sample_name}_output/~{sample_name}.log"
    }

    runtime {
        docker: "shapemapper:2.3"
        memory: "~{memory_gb}GB"
        cpu: cpu
    }
}
