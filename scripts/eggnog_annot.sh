export EGGNOG_DATA_DIR=/home/camcd/eggnog-mapper-data

nohup emapper.py --cpu 20 -m diamond --dmnd_db /home/camcd/eggnog-mapper-data/teleostei.dmnd -i ../genome_ncbi/etheo/GCF_013103735.1_CSU_Ecrag_1.0_protein.faa -o emapper_teleostei &
