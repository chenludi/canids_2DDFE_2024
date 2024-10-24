# 2024/10/03
# Try to fit with split_asym_mig
# Split into two populations of specifed size, with migration.
# params = (nu1,nu2,T,m12,m21) ns = (n1,n2)

# Make the p0 file for demographic inference
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_script=$dir_home'/script'
script=$dir_script"/make_p0_demoparamsonly.py"
outputdir=$dir_home'/dadi_initialparams'
model=split_asym_mig
pmarker=2

lrange_demo="1e-8,1e-8,1e-8,1e-8,1e-8"
urange_demo="10,10,1000,1000,1000"
p0lrange_demo="1e-6,1e-6,1e-6,1e-6,1e-6,1e-6"
p0urange_demo="8,8,800,800,800"
num_points=6
narrange=True
. /u/local/Modules/default/init/modules.sh
module load anaconda3
conda activate /u/home/c/cdi/condaenv/dadi0315
python $script -numr 2 -odir $outputdir -m $model -pmarker $pmarker -lr $lrange_demo -ur $urange_demo -p0lr $p0lrange_demo -p0ur $p0urange_demo -nump $num_points -narrange $narrange


# 2. fit the demo models.
# reference: the pipe_std.sh
# I have already made the initial params to start with.
# 3. pipe_inferdemo
model=split_asym_mig
# list of demographi model in this script
# 1. split_b1_mig (nu1,nu2,nu1b,Ts,Tb1,m), 2. split_b2_mig (nu1,nu2,nu2b,Ts,Tb2,m), 
# 3. split_bottlesync_mig (nu1,nu2,nu1b,nu2b,Ts,Tb,m), 
# 4. split_bottle1_mig (nu1,nu2,nu1b,nu2b,Ts,Tb1,Tb2,m), 
# 5. split_bottle2_mig (nu1,nu2,nu1b,nu2b,Ts,Tb1,Tb2,m)
pmarker=2
# Because there are too many jobs to submit and won't run at the same time
# Create a file to store the jobs
fsfilenames=(AW_LB.26.18.S.fs AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
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
model=split_asym_mig
#fsfilenames=(AW_LB.26.18.S.fs 
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
pmarker=2
date=1009
# Because there are too many jobs to submit and won't run at the same time
# Create a file to store the jobs
model=split_asym_mig
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
pmarker=2
fsfilenames=(AW_LB.26.18.S.fs)
# AW_PG.26.28.S.fs AW_BC.26.12.S.fs)
dir_home=/u/home/c/cdi/project-klohmuel/dog_2408
dir_script=$dir_home'/script'
script=$dir_script"/pipe_std_5_sumdemo.sh"
chmod +x $script
$script $output_sum $pmarker ${fsfilenames[@]}

