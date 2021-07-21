#!/bin/bash

#SBATCH -p palamut-cuda
#SBATCH -M truba
#SBATCH -A omalcioglu
#SBATCH -J vasp-test
#SBATCH --ntasks-per-node=16
#SBATCH --gres=gpu:1
#SBATCH --time=03:00:00
#SBATCH -N 1
#SBATCH --output=slurm-%j.out
#SBATCH --error=slurm-%j.err


#echo "SLURM_NODELIST $SLURM_NODELIST"
#echo "NUMBER OF CORES $SLURM_NTASKS"

#export OMP_NUM_THREADS=1

source /truba/sw/centos7.3/comp/intel/PS2018-update2/bin/compilervars.sh intel64
module load centos7.3/comp/intel/PS2018-update2

module load nvhpc/21.5 palamut/vasp/nvhpc/6.2-openACC

WORKPATH="/truba_scratch/omalcioglu/tugberkozdemir/hf-test"
OUTPATH="/truba/home/omalcioglu/tugberkozdemir/hf-test"

x="x"

echo "$(tput setaf 7)$(tput setab 3) HF@LDA (GPU, forever-diamond) $(tput sgr 0)"
echo ""

for k in 15
do
	for i in 4.070 #4.075 4.080 4.085 4.090 4.095 4.100 4.105 4.110 4.115 4.120
	do
		for mag in AF1 AF2 FM
		do
			rm -rf $WORKPATH/PLAYGROUND
			rm -rf $WORKPATH/STORAGE
			mkdir -p $WORKPATH/PLAYGROUND
			mkdir -p $WORKPATH/STORAGE


			mkdir -p $OUTPATH/$mag/LDA/$i/HF





			# Pre-converged DFT

			# Bring POTCAR to the PLAYGROUND:
			cp resources/POTCAR.LDA  $WORKPATH/PLAYGROUND/POTCAR

			# Bring POSCAR to the PLAYGROUND:
			cp resources/POSCAR-$mag-$i.vasp $WORKPATH/PLAYGROUND/POSCAR

			# Bring appropriate KPOINTS file to the PLAYGROUND
			cp resources/KPOINTS.$k        $WORKPATH/PLAYGROUND/KPOINTS


			touch  $WORKPATH/PLAYGROUND/INCAR


			if [ $mag == "AF1" ]
			then
				echo -e "SYSTEM = NiO-AF1-GROUNDSTATE\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "AF2" ]
			then
				echo -e "SYSTEM = NiO-AF2-GROUNDSTATE\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "FM" ]
			then
				echo -e "SYSTEM = NiO-FM-GROUNDSTATE\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			echo -e "EDIFF = 1E-8\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "PREC = Accurate\n" >> $WORKPATH/PLAYGROUND/INCAR


			echo -e "ENCUT = 600\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "ENAUG = 1200\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "ISMEAR = 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "SIGMA = 0.01\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "LMAXMIX = 4\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "LASPH = .TRUE.\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "ISPIN = 2\n" >> $WORKPATH/PLAYGROUND/INCAR

			if [ $mag == "AF1" ]
			then
				echo -e "MAGMOM = 2 -2 0 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "AF2" ]
			then
				echo -e "MAGMOM = 2 -2 0 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "FM" ]
			then
				echo -e "MAGMOM = 2 2 0 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi


			# Fire it up
			echo "$(tput setaf 4)$(tput setab 2) Starting DFT ($mag, a=$i, $k$x$k$x$k)... $(tput sgr 0)"
			start=`date +%s`
			mpirun -np 16 -wdir $WORKPATH/PLAYGROUND vasp_std
			end=`date +%s`
			runtime=$((end - start))
			echo "$(tput setaf 7)$(tput setab 4) DFT took $runtime seconds. $(tput sgr 0)"
			echo "$(tput setaf 4)$(tput setab 2) Finished DFT... $(tput sgr 0)"

			cp	$WORKPATH/PLAYGROUND/INCAR	$OUTPATH/$mag/LDA/$i/HF/INCAR.DFT
			cp	$WORKPATH/PLAYGROUND/POSCAR	$OUTPATH/$mag/LDA/$i/HF/
			cp	$WORKPATH/PLAYGROUND/KPOINTS	$OUTPATH/$mag/LDA/$i/HF/KPOINTS.$k
			cp	$WORKPATH/PLAYGROUND/OUTCAR	$OUTPATH/$mag/LDA/$i/HF/OUTCAR.DFT.$k$x$k$x$k









			rm $WORKPATH/PLAYGROUND/INCAR
			touch $WORKPATH/PLAYGROUND/INCAR

			if [ $mag == "AF1" ]
			then
				echo -e "SYSTEM = NiO-AF1-HF\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "AF2" ]
			then
				echo -e "SYSTEM = NiO-AF2-HF\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "FM" ]
			then
				echo -e "SYSTEM = NiO-FM-HF\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi



			echo -e "ALGO = EIGENVAL\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "NELM = 1\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "LHFCALC = .TRUE.\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "AEXX = 1.0\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "ALDAC = 0.0\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "AGGAC = 0.0\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "EDIFF = 1E-8\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "PREC = Acurate\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "ENCUT = 600\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "ENAUG = 1200\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "ISMEAR = 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			echo -e "SIGMA = 0.01\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "LMAXMIX = 4\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "LASPH = .TRUE.\n" >> $WORKPATH/PLAYGROUND/INCAR

			echo -e "ISPIN = 2\n" >> $WORKPATH/PLAYGROUND/INCAR

			if [ $mag == "AF1" ]
			then
				echo -e "MAGMOM = 2 -2 0 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "AF2" ]
			then
				echo -e "MAGMOM = 2 -2 0 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			if [ $mag == "FM" ]
			then
				echo -e "MAGMOM = 2 2 0 0\n" >> $WORKPATH/PLAYGROUND/INCAR
			fi

			# Fire it up
			echo "$(tput setaf 4)$(tput setab 2) Starting HF ($mag, a=$i, $k$x$k$x$k)... $(tput sgr 0)"
			start=`date +%s`
			mpirun -np 16 -wdir $WORKPATH/PLAYGROUND vasp_std
			end=`date +%s`
			runtime=$((end - start))
			echo "$(tput setaf 7)$(tput setab 4) HF took $runtime seconds. $(tput sgr 0)"
			echo "$(tput setaf 4)$(tput setab 2) Finished HF... $(tput sgr 0)"

			cp	$WORKPATH/PLAYGROUND/INCAR	$OUTPATH/$mag/LDA/$i/HF/INCAR.HF
			cp	$WORKPATH/PLAYGROUND/OUTCAR	$OUTPATH/$mag/LDA/$i/HF/OUTCAR.HF.$k$x$k$x$k

		done ## end of each magnetism
	done # end of various lattice parameters
done ## end of kpoints
