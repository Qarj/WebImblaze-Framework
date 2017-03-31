#!/usr/bin/env python3
import sys,os,configparser,platform,ctypes,time,subprocess

def localtime():
    return time.asctime( time.localtime(time.time()) )

def get_free_space(folder, format="MB"):
    """ 
        Return folder/drive free space 
    """
    fConstants = {"GB": 1073741824,
                  "MB": 1048576,
                  "KB": 1024,
                  "B": 1
                  }
    if platform.system() == 'Windows':
        free_bytes = ctypes.c_ulonglong(0)
        ctypes.windll.kernel32.GetDiskFreeSpaceExW(ctypes.c_wchar_p(folder), None, None, ctypes.pointer(free_bytes))
        return (int(free_bytes.value/fConstants[format.upper()]), format)
    else:
        return (int(os.statvfs(folder).f_bfree*os.statvfs(folder).f_bsize/fConstants[format.upper()]), format)

def output_free_space():
    c_mb = (get_free_space(r"C:", "MB"))[0]
    d_mb = (get_free_space(r"D:", "MB"))[0]
    log.write("\nFree Space on C: "+str(c_mb)+" MB\n")
    log.write("Free Space on D: "+str(d_mb)+" MB\n\n")


def remove_old(path,days):
    if not os.path.isdir(path):
        return "Skipping "+path+" - folder not found\n"
    result = subprocess.run(["python", script_folder + '/../tools/remove-old.py', path, "--older-than-days",str(days)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    #print ("Args:", result.args)
    return result.stdout.decode()

script_folder = (os.path.dirname(os.path.realpath(__file__)))

config = configparser.ConfigParser()
config.read(script_folder + '/../wif.config')

#print (config.sections())
try:
    inetpub = (config['path']['web_server_location_full'])
except KeyError:
    print ('Could not find web_server_locaiton_full value in path section of',script_folder + '/../wif.config')
    sys.exit()

#print ('inetpub location:', inetpub)

log_file_full = inetpub + '/logs/ResultsCleanup.txt'

log = open(log_file_full, "a+")

log.write('\n--------------------------------------------------------------------\n')
log.write('Started tasks/ResultsCleanup.py at '+localtime()+'\n')

output_free_space()

log.write("--> Removing results files under: "+inetpub+"\n\n")

log.write(remove_old(inetpub+'/DEV',100))
log.write(remove_old(inetpub+'/PAT',100))
log.write(remove_old(inetpub+'/PROD',100))

log.write("\n--> Removing Temporary WebInject Files\n")

log.write(remove_old('/webinjectDEV/temp',2))
log.write(remove_old('/webinjectPAT/temp',2))
log.write(remove_old('/webinjectPROD/temp',2))
log.write(remove_old('/webinject/temp',2))

log.write("\n--> Removing Temporary Files left by Chrome\n")
username = (os.environ['USERNAME'])
log.write(remove_old('C:/Users/'+username+'/AppData/Local/Temp',7))

log.write("\n--> Removing old D:\\Temp Files\n")
log.write(remove_old('D:/Temp',7))

output_free_space()

log.write('Ended at '+localtime()+'\n\n')

log.close