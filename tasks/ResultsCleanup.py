#!/usr/bin/env python3

import configparser
import ctypes
import os
import platform
import subprocess
import sys
import time


def localtime():
    return time.asctime(time.localtime(time.time()))


def get_free_space(folder, format="MB"):
    """
    Return folder/drive free space
    """
    fConstants = {"GB": 1073741824, "MB": 1048576, "KB": 1024, "B": 1}
    if platform.system() == "Windows":
        free_bytes = ctypes.c_ulonglong(0)
        ctypes.windll.kernel32.GetDiskFreeSpaceExW(
            ctypes.c_wchar_p(folder), None, None, ctypes.pointer(free_bytes)
        )
        return (int(free_bytes.value / fConstants[format.upper()]), format)
    else:
        return (
            int(
                os.statvfs(folder).f_bfree
                * os.statvfs(folder).f_bsize
                / fConstants[format.upper()]
            ),
            format,
        )


def output_free_space():
    c_mb = (get_free_space(r"C:", "MB"))[0]
    d_mb = (get_free_space(r"D:", "MB"))[0]
    log("\nFree Space on C: " + str(c_mb) + " MB\n")
    log("Free Space on D: " + str(d_mb) + " MB\n\n")


def remove_old(path, days, exclude=""):
    if not os.path.isdir(path):
        return "Skipping " + path + " - folder not found\n"

    exclude_option = ""
    if exclude:
        exclude_option = " --exclude "

    result = subprocess.run(
        "python "
        + script_folder
        + "/../tools/remove-old.py "
        + path
        + " --older-than-days "
        + str(days)
        + exclude_option
        + exclude,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )

    return result.stdout.decode()


def log(text):
    # open and close log file every time in case the script crashes or hangs
    logFile = open(log_file_full, "a+")
    logFile.write(text)
    logFile.close


# script_folder = (os.path.dirname(os.path.realpath(__file__)))
script_absolute_path = os.path.abspath(__file__)
script_folder = os.path.dirname(script_absolute_path)
os.chdir(script_folder)  # change current directory to script folder

config = configparser.ConfigParser()
config.read(script_folder + "/../wif.config")

# print (config.sections())
try:
    inetpub = config["path"]["web_server_location_full"]
except KeyError:
    print(
        "Could not find web_server_location_full value in path section of",
        script_folder + "/../wif.config",
    )
    sys.exit()

# print ('inetpub location:', inetpub)

log_file_full = inetpub + "/logs/ResultsCleanup.txt"

log("\n--------------------------------------------------------------------\n")
log("Started tasks/ResultsCleanup.py at " + localtime() + "\n")

output_free_space()

log("--> Removing results files under: " + inetpub + "\n\n")

log(remove_old(inetpub + "/DEV", 100, exclude=".xml"))
log(remove_old(inetpub + "/PAT", 100, exclude=".xml"))
log(remove_old(inetpub + "/PROD", 100, exclude=".xml"))

log(remove_old(inetpub + "/DEV", 2000))
log(remove_old(inetpub + "/PAT", 2000))
log(remove_old(inetpub + "/PROD", 2000))

log("\n--> Removing Temporary WebImblaze Files\n")

log(remove_old("/webimblazeDEV/temp", 2))
log(remove_old("/webimblazePAT/temp", 2))
log(remove_old("/webimblazePROD/temp", 2))
log(remove_old("/webimblaze/temp", 2))

log("\n--> Removing Temporary Files left by Chrome\n")
username = os.environ["USERNAME"]
log(remove_old("C:/Users/" + username + "/AppData/Local/Temp", 7))

log("\n--> Removing old D:\\Temp Files\n")
log(remove_old("D:/Temp", 7))

output_free_space()

log("Ended at " + localtime() + "\n\n")
