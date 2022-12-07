### this is the clunky way I turned output from STAR into a matrix of read counts for edgeR

# copy all ReadsPerGene files to new dir
mkdir reads_to_counts
cp *ReadsPerGene.out.tab /reads_to_counts
cd reads_to_counts

# strip file extentions
for file in *.tab; do
    mv -- "$file" "${file%%.*}"
done

# paste filenames into file
ls * | paste -s - > samplenames.txt #get sample names

for i in *trimmed; do
    awk '{print $2}' $i > $i.unstranded;
done #extract counts column for unstranded lib prep

paste *.unstranded | column -s $'\t' -t > unstranded_counts.txt #paste to matrix

cat samplenames.txt unstranded_counts.txt > unstranded_counts_matrix.txt #add headers

awk '{print $1}' 4B-ASaN_S15_L002_R1_001_trimmed | paste - unstranded_counts_matrix.txt > readcountsmatrix.txt #add gene id column
