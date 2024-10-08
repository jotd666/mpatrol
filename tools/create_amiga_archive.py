import subprocess,os,glob,shutil

progdir = os.path.abspath(os.path.join(os.path.dirname(__file__),os.pardir))

gamename = "mpatrol"
# JOTD path for cranker, adapt to wh :)
os.environ["PATH"] += os.pathsep+r"K:\progs\cli"

cmd_prefix = ["make","-f",os.path.join(progdir,"makefile.am")]

subprocess.check_call(cmd_prefix+["clean"],cwd=os.path.join(progdir,"src"))

for s in ["convert_sounds.py","convert_graphics_aga.py","convert_graphics_ecs.py"]:
    subprocess.check_call(["cmd","/c",s],cwd=os.path.join(progdir,"assets","amiga"))

subprocess.check_call(cmd_prefix+["RELEASE_BUILD=1"],cwd=os.path.join(progdir,"src"))
# create archive

outdir = os.path.join(progdir,f"{gamename}_HD")
print(outdir)
if os.path.exists(outdir):
    for x in glob.glob(os.path.join(outdir,"*")):
        os.remove(x)
else:
    os.mkdir(outdir)
for file in ["readme.md",f"{gamename}.slave",f"{gamename}_aga.slave"]:
    shutil.copy(os.path.join(progdir,file),outdir)

shutil.copy(os.path.join(progdir,"assets","amiga","MoonPatrolGlowIcon.info"),outdir)
shutil.copy(os.path.join(progdir,"assets","amiga","MoonPatrol_GI.info"),outdir)
shutil.copy(os.path.join(progdir,"assets","amiga","MoonPatrol.info"),outdir)
shutil.copy(os.path.join(progdir,"assets","amiga","boxart.png"),outdir)

for suffix in ["ocs","ecs","aga"]:
    # pack the file for floppy
    exename = f"{gamename}_{suffix}"
    shutil.copy(os.path.join(progdir,exename),outdir)
    subprocess.check_output(["cranker_windows.exe","-f",os.path.join(progdir,exename),"-o",os.path.join(progdir,f"{exename}.rnc")])