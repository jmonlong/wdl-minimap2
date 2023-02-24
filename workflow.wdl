version 1.0


task alignAndSortBAM {
    input {
        File target_seq_file
        File query_seq_file
        String preset = "map-ont"
        Boolean eqx = true
        Boolean secondary = false
        Int kmerSize = 17
        Int minMinimizers = 10
        String batchSize = "4g"
        String indexSplitBp = "8g"
        String otherArgs = ""
        String out_label = "alignment"
        String sortMemory = "4G"
        Int cores = 64
        Int disk = 10 * round(size(target_seq_file, 'G') + size(query_seq_file, 'G')) + 50
        Int mem = 100
        String container
        Int preemptible = 1
    }

    Int alignThreads = if cores < 16 then ceil(cores/2) else cores - 8
    Int sortThreads = if cores < 16 then floor(cores/2) else 8

    command <<<
        input_path="~{query_seq_file}"
        fasta_path=""

        if [ ${input_path: -4} == ".bam" ]
        then
            echo "converting BAM input..."
            fasta_path="${input_path:0:-4}.fasta"
            samtools fasta ${input_path} > ${fasta_path}
        else
            fasta_path="${input_path}"
        fi

        echo ${fasta_path}

        set -eux -o pipefail

        minimap2 -t ~{alignThreads} ~{true="--eqx" false="" eqx} -x ~{preset} \
                 -n ~{minMinimizers} -a -K ~{batchSize} -k ~{kmerSize} -I ~{indexSplitBp} \
                 --secondary=~{true="yes" false="no" secondary} ~{otherArgs} \
                 ~{target_seq_file} ${fasta_path} | samtools sort -m ~{sortMemory} -o ~{out_label}.bam -O BAM -@ ~{sortThreads}

        samtools index ~{out_label}.bam ~{out_label}.bam.bai
    >>>

    output {
        File bam= "~{out_label}.bam"
        File bam_index= "~{out_label}.bam.bai"
    }
    runtime {
        docker: container
        memory: mem + " GB"
        cpu: cores
        disks: "local-disk " + disk + " SSD"
        preemptible: preemptible
    }
}



workflow minimap2 {
    meta {
	author: "Jean Monlong"
        email: "jmonlong@ucsc.edu"
        description: "Align two sets of sequences using minimap2 into a sorted BAM. FASTA or unmapped BAMs accepted as input."
    }
    input {
        File TARGET_SEQ_FILE
        File QUERY_SEQ_FILE
        String DOCKER_CONTAINER = "quay.io/jmonlong/minimap2_samtools:v2.24_v1.16.1"
        Int CORES = 64
        Int MEM = 100
    }

    call alignAndSortBAM {
        input:
        target_seq_file=TARGET_SEQ_FILE,
        query_seq_file=QUERY_SEQ_FILE,
        container=DOCKER_CONTAINER,
        cores=CORES,
        mem=MEM
    }

    output {
        File bam = alignAndSortBAM.bam
        File bam_index = alignAndSortBAM.bam_index
    }
}

