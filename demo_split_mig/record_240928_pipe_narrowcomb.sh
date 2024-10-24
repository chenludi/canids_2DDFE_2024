# 2024/09/28
#2024/09/28
# Make the p0 file for demographic inference
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_script=$dir_home'/script'
script=$dir_script"/make_p0_demoparamsonly.py"
outputdir=$dir_home'/dadi_initialparams'
model=split_mig
#nu1, nu2, T,m
pmarker=3

lrange_demo="0.01,0.01,1e-4,1e-4"
urange_demo="1,1,10,10"
p0lrange_demo="0.05,0.05,1e-3,1e-3"
p0urange_demo="0.8,0.8,5,5"
num_points=8
narrange=True
. /u/local/Modules/default/init/modules.sh
module load anaconda3
conda activate /u/home/c/cdi/condaenv/dadi0315
python $script -numr 2 -odir $outputdir -m $model -pmarker $pmarker -lr $lrange_demo -ur $urange_demo -p0lr $p0lrange_demo -p0ur $p0urange_demo -nump $num_points -narrange $narrange

# 2. fit the demo models.
# reference: the pipe_std.sh
# I have already made the initial params to start with.
# 3. pipe_inferdemo
model=split_mig
# list of demographi model in this script
# 1. split_b1_mig (nu1,nu2,nu1b,Ts,Tb1,m), 2. split_b2_mig (nu1,nu2,nu2b,Ts,Tb2,m), 
# 3. split_bottlesync_mig (nu1,nu2,nu1b,nu2b,Ts,Tb,m), 
# 4. split_bottle1_mig (nu1,nu2,nu1b,nu2b,Ts,Tb1,Tb2,m), 
# 5. split_bottle2_mig (nu1,nu2,nu1b,nu2b,Ts,Tb1,Tb2,m)
pmarker=3
# Because there are too many jobs to submit and won't run at the same time
# Create a file to store the jobs
#fsfilenames=(AW_LB.26.18.S.fs)
fsfilenames=(AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_script=$dir_home'/script'
script=$dir_script"/pipe_std_3_inferdemo.sh"
chmod +x $script
$script $model $pmarker ${fsfilenames[@]}

# submit jobs
module load tmux
tmux new -t run
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_script=$dir_home'/script'
cd $dir_script
model=split_mig
#fsfilenames=(AW_LB.26.18.S.fs)
fsfilenames=(AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
for fsfilename in ${fsfilenames[@]}
    do
    file_jobs=$dir_script"/jobs_inferdemo_"$model"_"$fsfilename".sh"
    ls $file_jobs
    head -1 $file_jobs
    script=$dir_script"/submit_jobs.sh"
    chmod +x $script
    $script $file_jobs
done

tmux detach
# 4. plot demo
# list of demographi model in this script
# 1. split_b1_mig (nu1,nu2,nu1b,Ts,Tb1,m)
# 2. split_b2_mig (nu1,nu2,nu2b,Ts,Tb2,m), 
# 3. split_bottlesync_mig (nu1,nu2,nu1b,nu2b,Ts,Tb,m), 
# 4. split_bottle1_mig (nu1,nu2,nu1b,nu2b,Ts,Tb1,Tb2,m), 
# 5. split_bottle2_mig (nu1,nu2,nu1b,nu2b,Ts,Tb1,Tb2,m) 
chmod +x $dir_script'/hpctool_trackjob.sh'
$dir_script'/hpctool_trackjob.sh'
pmarker=3
date=0929
# Because there are too many jobs to submit and won't run at the same time
# Create a file to store the jobs
model=split_mig
fsfilenames=(AW_LB.26.18.S.fs AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_script=$dir_home'/script'
script=$dir_script"/pipe_std_4_plotdemo.sh"
. /u/local/Modules/default/init/modules.sh
module load anaconda3
conda activate /u/home/c/cdi/condaenv/dadi0315
chmod +x $script
cd $dir_script
$script $model $pmarker $date ${fsfilenames[@]}
# 5. pipe_std_5_sumdemo
# Put all the best_inference.txt files together and write a summary table
date=0930
output_sum=$dir_home'/output_demog/summary_demog_'$date'.csv'
pmarker=3
fsfilenames=(AW_LB.26.18.S.fs AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_script=$dir_home'/script'
script=$dir_script"/pipe_std_5_sumdemo.sh"
chmod +x $script
$script $output_sum $pmarker ${fsfilenames[@]}

# 6. Generate cache
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_fs=$dir_home'/input_fs'
#fsfilenames=(AW_LB.26.18.S.fs 
fsfilenames=(AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
# write the list of fsfiles
fsfiles=()
for fsfilename in ${fsfilenames[@]}
    do
    fsfiles+=($dir_fs'/'$fsfilename)
done
models=(split_mig)
# model_sel = $model"_sel"
# Only useful for 2D models
for model in ${models[@]}
    do
    dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
    parammarker="3" # Parameter marker
    cachemarker="1" # Cache marker
    grid="1500 1520 1540"
    numcpus=10
    gamma_pts=300
    dir_script=$dir_home'/script'
    script=piperef_stddfe_6_cache.sh
    chmod +x $dir_script/$script
    cd $dir_script
    $dir_script/$script --fsfiles ${fsfiles[@]} --model $model --parammarker $parammarker --cachemarker $cachemarker --grid "$grid" --numcpus $numcpus --gamma_pts $gamma_pts
done

tmux new -t cache
module load conda
conda activate ~/condaenv/dadi0315
dadi-cli GenerateCache --model split_mig_sel --dimensionality 2 --demo-popt /u/home/c/cdi/project-klohmuel/dog_2408/output_demog/split_mig.AW_LB.26.18.S.3/split_mig.AW_LB.26.18.S.2113.InferDM.bestfits --sample-size 27 19 --grids 1500 1520 1540 --gamma-pts 300 --gamma-bounds 0.0406903880 20345.1940111879 --output /u/home/c/cdi/project-klohmuel/dog_2408/output_demog/split_mig.AW_LB.26.18.S.3/cache_1.spectra.bpkl --cpus 10



dadi-cli GenerateCache --model split_mig_sel --dimensionality 2 --demo-popt /u/home/c/cdi/project-klohmuel/dog_2408/output_demog/split_mig.AW_LB.26.18.S.3/split_mig.AW_LB.26.18.S.2113.InferDM.bestfits --sample-size 27 19 --grids 50 52 54 --gamma-pts 2 --gamma-bounds 0.0406903880 20345.1940111879 --output /u/home/c/cdi/project-klohmuel/dog_2408/output_demog/split_mig.AW_LB.26.18.S.3/cache_1.spectra.bpkl --cpus 1

# The cache file failes in generating. Use python script from dadi directly, instead of using dadi-cli






