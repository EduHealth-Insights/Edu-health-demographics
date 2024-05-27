######################################################################################
##																					##
##	ExecuteJobsWithList.ps1: Program to launch several Stata jobs at the same		##
##		time, with a limited number of CPU, when max is reched, it waits for a free	##
##		CPU, meaning one Stata Job is over.											##
##																					##
## Input: A csv file with the list of jobs											##
##																					##
## To Notice: This is adapted from G.Bousquet's programs.  							##
## 				Check original for updates.											##
## 				All code files need to be copied (not cloned) to 					##
##				V:\PISA_INITIALREPORT_2022\sandbox\Trends\							##
##																					##
##	Original author: G.Bousquet EDU/ECS												##
##	Adapted and maintained by: F.Avvisati EDU/ECS									##
##																					##
######################################################################################

# Définir Temp Folder
$mytemp = "E:\TEMP\" + ($env:USERNAME).ToString()
Invoke-Command -argumentList $mytemp -scriptBlock {param([string]$path) $env:TEMP=$path } 
Invoke-Command -argumentList $mytemp -scriptBlock {param([string]$path) $env:TMP=$path } 
Invoke-Command -argumentList $mytemp -scriptBlock {param([string]$path) $env:TMPDIR=$path } 
Invoke-Command -argumentList $mytemp -scriptBlock {param([string]$path) $env:STATATMP=$path } 

# Lire le fichier CSV
$csv = Import-Csv -Path "V:\PISA_INITIALREPORT_2022\sandbox\Trends_CH7\Listofjobs_trends_ch7.csv"

# Initialiser les variables
$runningJobs = 0
$MaxJobsAtTheSameTime = 12

# Tant qu'il y a des jobs à lancer ou en cours d'exécution
while ($csv.Count -gt 0) {
    # Parcourir les lignes du fichier CSV
    foreach ($row in $csv) {
        # Vérifier si un job peut être lancé
        if ($runningJobs -lt $MaxJobsAtTheSameTime) {
            # Récupérer les valeurs des paramètres
            $column1 = $row.Location
            $column2 = $row.Program
            $column3 = $row.jobNumber
            $column4 = $row.database
            $column5 = $row.domn
            $column6 = $row.outfile
            $column7 = $row.countries
            $column8 = $row.repestoptions
            $column9 = $row.coverage
            $column10 = $row.param1
            $column11 = $row.param2

            # Concatener pour le rogramme
            $ProgToRun = -join($column1,$column2)
            write-host $ProgToRun $column3 $column4 $column5 $column6 $column7 $column8 $column9 $column10 $column11 

            # Former la commande à exécute
            Invoke-Expression "start-job -scriptblock {P:\Stata\Current\StataMP-64 /e do $ProgToRun $column3 $column4 $column5 $column6 $column7 $column8 $column9 $column10 $column11}"
            $runningJobs++
            # Supprimer la ligne du fichier CSV
            $csv = $csv | Where-Object { $_ -ne $row }
        }
    }

    # Attendre un peu avant de vérifier l'état des jobs à nouveau
    Start-Sleep -Seconds 30

    # Verifier le nombre de process Stata qui tournent toujours
    $ProcessStata = (Get-Process -ProcessName StataMP-64).Count
    if($ProcessStata -lt $runningJobs) {
        $runningJobs = $ProcessStata
        write-host "A Stata program just ended, check logs, a new progam will start running in 10 secondes"
    }
    


}

