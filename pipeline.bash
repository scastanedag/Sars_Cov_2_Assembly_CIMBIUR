# Preparación
# Configure el entorno informático. 
# Esto debe hacerse y probarse antes de la secuenciación, especialmente si se hará en un entorno sin acceso a Internet o donde sea lento o poco confiable. 
# Una vez hecho esto, la bioinformática se puede realizar en gran medida fuera de línea.

# Solo la primera vez:

git clone https://github.com/artic-network/artic-ncov2019.git
cd artic-ncov2019
conda env remove -n artic-ncov2019
conda env create -f environment.yml

#Activar el entorno ARTIC

export PATH=/home/admin.cn02/miniconda3/bin:$PATH
source activate /home/admin.cn02/anaconda2/envs/artic-ncov2019	


#basecalling

# Dirigirse a la carpeta donde está ont-guppy, pwd:

./guppy_basecaller -c dna_r9.4.1_450bps_fast.cfg -i /fast5_pass -s /Basecalling_file/  --cpu_threads_per_caller 34 -r  --num_callers 4

# Cambiar la ruta donde están los fast5_pass (-i) y donde quedarán los fastq (-s)

# Demultiplexing 

# Asignación por barcodes de los reads previamente llamados. Aquí es importante asignar correctamente el parámetro --barcode_kits para que se puedan asignar adecuadamente

./guppy_barcoder --require_barcodes_both_ends -i /Basecalling_file/ -s /Basecalling_file/barcodes --barcode_kits EXP-NBD196

# cambiar el -i por la carpeta donde quedaron las lecturas fastq con basecalling. Cambiar el -s que corresponde a la carpeta donde quedaran los archivos por barcode
# poner correctamente el --barcode_kits ya que con base en este se hace la asignación 

# ya con las lecturas asignadas por barcode, se realiza el merge de lecturas por cada barcode y se realiza filtro de calidad. 
# esto se realiza en la carpeta que fue creada para guardar los archivos resultantes del ensamblaje

artic guppyplex --min-length 400 --max-length 700 --directory /fastq_pass/barcode20 --prefix /Ensamblajes_Artic/Ensamblajes_file/codigo_interno_muestra

#cambiar el --directory. Allí para cada muestra se pone el barcode que corresponda que está fastq_pass y en --prefix se pone la carpeta del ensamblaje que se esté realizando 
# y el código de muestra interno que corresponde a ese barcode en dicha corrida

#ensamblaje con fase final Con medaka
# Una alternativa al nanopolish a las variantes de llamada es usar medaka. 
# Medaka es más rápido que el nanopolish y parece funcionar de manera casi equivalente en las pruebas.
# Para utilizar Medaka, se puede omitir el nanopolish al agregar el parámetro --medaka al comando:

artic minion --medaka --normalise 200 --threads 48  --scheme-directory /datagimur/GIMUR2/MM-zips/artic-ncov2019/primer_schemes --read-file /Ensamblajes_file/codigo_interno_barcodexx.fastq 
--fast5-directory /fast5_pass nCoV-2019/V3 codigo_interno

#aquí se debe cambiar la ruta donde están los fast5_pass, la ruta donde está el ensamblaje en cuestión y el archivo generado en el paso anterior que 
#tiene como nombre el código interno unido al barcode al que corresponde. Al final después de nCoV-2019/V3 se debe también poner el codigo_interno para 
#que así genere los archivos del ensamblaje con ese prefijo


#el ensamblaje también se puede hacer con nanopolish en vez de con medaka así:

artic minion --normalise 200 --threads 48  --scheme-directory /datagimur/GIMUR2/MM-zips/artic-ncov2019/primer_schemes 
--read-file /Ensamblajes_file/codigo_interno_barcodexx.fastq --fast5-directory  /fast5_pass --sequencing-summary /sequencing_summary.txt nCoV-2019/V3 codigo_interno

#aquí se debe cambiar la ruta donde están los fast5_pass, la ruta donde está el ensamblaje en cuestión y el archivo generado en el paso anterior que 
#tiene como nombre el código interno unido al barcode al que corresponde. Al final después de nCoV-2019/V3 se debe también poner el codigo_interno para 
#que así genere los archivos del ensamblaje con ese prefijo
#adicionalmente se debe poner la ruta del archivo sequencing_summary que se encuentra dentro de los output en la carpeta de secuenciación
#o en la carpeta donde se hizo el basecalling dependiendo del caso

#copiar todas los consensus.fasta que está en cada uno de los archivos output del ensamblaje por barcode en una única carpeta
#posteriormente unir secuencias consenso para análisis de linaje y mutaciones

cat *.fasta | sed 's/>/\n>/g' | sed '1d' > nombre_corrida_consensus.fasta


#realizar las asignaciones por medio de PANGOLIN y la búsqueda de mutaciones por Nextclades



