# 6. Generate cache

fsfilenames=(AW_LB.26.18.S.fs AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
# write the list of fsfiles
model=split_mig
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
parammarker="3" # demo Parameter marker
cachemarker="1" # Cache marker
#grids="300 350 400"
#gammapts=50
for fsfilename in ${fsfilenames[@]}
    do
qsub submit_dadi-cli_cache2d.sh --fsfilename $fsfilename --model $model --pmarker $parammarker --cachemarker $cachemarker --grids "300 350 400" --gammapts 50

done
for fsfilename in ${fsfilenames[@]}
    do
qsub submit_dadi-cli_cache1d.sh --fsfilename $fsfilename --model $model --pmarker $parammarker --cachemarker $cachemarker --grids "300 350 400" --gammapts 50

done
# 10/11/12:18am 
Your job 5075638 ("cache2d") has been submitted
Your job 5075639 ("cache2d") has been submitted
Your job 5075640 ("cache2d") has been submitted
Your job 5075646 ("cache1d") has been submitted
Your job 5075647 ("cache1d") has been submitted
Your job 5075648 ("cache1d") has been submitted

fsfilenames=(AW_LB.26.18.S.fs AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
# write the list of fsfiles
model=split_mig
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
parammarker="3" # demo Parameter marker
cachemarker="2" # Cache marker
#grids="300 350 400"
#gammapts=50
for fsfilename in ${fsfilenames[@]}
    do
qsub submit_dadi-cli_cache2d.sh --fsfilename $fsfilename --model $model --pmarker $parammarker --cachemarker $cachemarker --grids "600 650 700" --gammapts 50

done
for fsfilename in ${fsfilenames[@]}
    do
qsub submit_dadi-cli_cache1d.sh --fsfilename $fsfilename --model $model --pmarker $parammarker --cachemarker $cachemarker --grids "600 650 700" --gammapts 50

done

Your job 5075642 ("cache2d") has been submitted
Your job 5075643 ("cache2d") has been submitted
Your job 5075644 ("cache2d") has been submitted




# 2024/10/10
# Infer DFE
# I can fit

# run single test for different distributions

fsfilenames=(AW_LB.26.18.NS.fs AW_PG.26.28.NS.fs AW_BC.26.12.NS.fs)
for fsfilename in ${fsfilenames[@]}
    do
dir_fsfile=/u/home/c/cdi/project-klohmuel/dog_2408/input_fs
fsfile=$dir_fsfile'/'$fsfilename
pdf2d=biv_lognormal
p0="1 1 0.5" #mu,sigma,rho
lbounds="0.01 0.001 0" 
ubounds="10 10 1"
dfemarker=00
line=$dfemarker' '$p0' '$lbounds' '$ubounds
model=split_mig
pmarker=3
cachemarker=1
qsub submit_dadi-cli_2ddfe_single_manualparams.sh $fsfile $model $pmarker $pdf2d $cachemarker $line
done
Your job 5076078 ("dfe2dsin") has been submitted
Your job 5076079 ("dfe2dsin") has been submitted
Your job 5076080 ("dfe2dsin") has been submitted

#asymatric lognormal joint DFE
fsfilenames=(AW_LB.26.18.NS.fs AW_PG.26.28.NS.fs AW_BC.26.12.NS.fs)
for fsfilename in ${fsfilenames[@]}
    do
dir_fsfile=/u/home/c/cdi/project-klohmuel/dog_2408/input_fs
fsfile=$dir_fsfile'/'$fsfilename
pdf2d=biv_lognormal
p0="1 1 1 1 .5" #mu1,mu2,sigma1,sigma2,rho
lbounds="-10 -10 0.001 0.001 0.01"
ubounds="10 10 10 10 0.999"
dfemarker=a00
line=$dfemarker' '$p0' '$lbounds' '$ubounds
model=split_mig
pmarker=3
cachemarker=1
qsub submit_dadi-cli_2ddfe_single_manualparams.sh $fsfile $model $pmarker $pdf2d $cachemarker $line
done
# 2024/10/11
Your job 5076083 ("dfe2dsin") has been submitted
Your job 5076084 ("dfe2dsin") has been submitted
Your job 5076085 ("dfe2dsin") has been submitted


# Plot single inference

module load conda
conda activate ~/condaenv/dadi0315/

dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
date=241014
dir_mv=$dir_home'/mv_'$date
output_sum=$dir_mv'/sumdfe_'$date'.tsv'
mkdir -p $dir_mv

fsfilenames=(AW_LB.26.18.NS.fs AW_PG.26.28.NS.fs AW_BC.26.12.NS.fs)
bestfits=(00)
dir_script=$dir_home'/script'
script=$dir_script'/plot_fitted_dfe.py'
for fsfilename in ${fsfilenames[@]}
    do
for bestfit in ${bestfits[@]}
    do
    dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
    #bestfit=00
    pdf=None
    pdf2=biv_lognormal
    model=split_mig
    pmarker=3
    cachemarker=1
    dir_fsfile=/u/home/c/cdi/project-klohmuel/dog_2408/input_fs
    fsfile=$dir_fsfile'/'$fsfilename
    if [[ $fsfile == *.sfs ]]; then
        fsbasename=$(basename $fsfile .sfs)
    elif [[ $fsfile == *.fs ]]; then
        fsbasename=$(basename $fsfile .fs)
    else
        echo "Error: The fsfile, '$fsfile' does not end with .sfs or .fs."
        #exit 1
    fi
    fsbasenamesyn=${fsbasename//NS/S}
    dir_outdemog=$dir_home'/output_demog/'$model"."$fsbasenamesyn"."$pmarker
    dir_dfe=$dir_home'/output_dfe/'$model"."$pmarker"."$fsbasename'.'$pdf2d'.cache2d'$cachemarker
    dfepopt=$dir_dfe'/'$bestfit'.InferDFE.bestfits'
    output=$dfepopt'.pdf'
    cache1d=None
    cache2d=$dir_outdemog'/cache_2d_'$cachemarker'.spectra.bpkl'
    #conda activate ~/condaenv/dadi0315/
    #python $script --selePopt $dfepopt \
                    --fs $fsfile \
                    --cache1d $cache1d \
                    --cache2d $cache2d \
                    --pdf $pdf \
                    --pdf2 $pdf2 \
                    --output $output
    # copy and rename the output file for viewing
    # Get the name and smallest directory of the dfepopt
    dfepopt_name=$(basename $dfepopt)
    dfepopt_dir=$(dirname $dfepopt)
    smallest_dir=$(basename $dfepopt_dir)
    echo "dfepopt name: $dfepopt_name"
    echo "smallest directory: $smallest_dir"
    #cp $output $dir_mv'/'$smallest_dir'.'$dfepopt_name'.pdf'

    # put the inference together
    $dir_script'/sum_dfepopt.sh' $dfepopt
    $dir_script'/sum_dfepopt.sh' $dfepopt $dir_mv
done
done
# put dfe output table together
# cat the output to the summary file
cat *.tsv > $dir_mv'/temp.tsv'
# remove redundant lines
awk '!seen[$0]++' $dir_mv'/temp.tsv' > $output_sum
rm $dir_mv'/temp.tsv'











