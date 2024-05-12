#!/bin/bash

# Function for each task
getSonData() {

    read -p "Do you want to get the Heung-Min Son's data? (y/n) :" temp
    if [[ $temp == "y" ]]; then
        cat $1 | awk -F, '$1=="Heung-Min Son" {print "Team: " $4 ", Appearance: " $6 ", Goal: " $7 ", Assist: " $8}'
    fi
    echo
}


getTeamData() {

    read -p "What do you want to get the team data of league_position[1~20] : " temp1
    cat $1 | awk -F, -v temp1=$temp1 'NR==((temp1+1)) {printf "%d %s (%.6f)\n", temp1, $1, $2 / ($2+$3+$4)}' teams.csv
    echo
}

getTop3AttendanceMatches() {
    read -p "Do you want to know Top-3 attendance data and average attendance? (y/n) : " temp
    if [[ $temp == "y" ]]; then
        echo "***Top-3 Attendance Match***\n"
        cat $1 | sort -n -r -t',' -k 2 | head -3 | awk -F, '{print $3 " vs " $4 " (" $1 ")\n" $2 " " $7 "\n"}'
    fi
}

getTeamLeaguePositionAndTopScorer() {
    read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) : " temp
    if [[ $temp == "y" ]]; then

    
    cnt=1
    IFS="," 

    while read -r common_name wins draws losses points_per_game league_position cards_total shots fouls
    do
        if [ "$common_name" == "common_name" ]; then
            continue
        fi
        
        top_scorer=""
        max_goals=0

        while read -r full_name age position current_club nationality appearances_overall goals_overall assists_overall
            do
            if [ "$full_name" == "full_name" ]; then
                continue
            fi
            
            # 현재 팀의 선수인 경우
            if [ "$current_club" == "$common_name" ]; then
                # 현재 선수의 골 수가 최대 골 수보다 많은지 확인.
                if [ "$goals_overall" -ge "$max_goals" ]; then
                    max_goals=$goals_overall
                    top_scorer=$full_name
                fi
            fi
        done < $2
        
        echo
        echo "$cnt $common_name"
        echo "$top_scorer $max_goals"
        cnt=$((cnt+1))

    done < $1
        echo
    fi
    }

getModifiedDateFormat() {
    read -p "Do you want to modify the format of date? (y/n) : " temp
    if [[ $temp == "y" ]]; then
        cat $1 | awk -F, 'NR>1 { print $1 }' | sed -E 's/([A-Za-z]+) ([0-9]+) ([0-9]+) - ([0-9]+):([0-9]+)([ap]m)/\3\/\1\/\2 \4:\5\6/' | sed -E 's/Jan/01/;s/Feb/02/;s/Mar/03/;s/Apr/04/;s/May/05/;s/Jun/06/;s/Jul/07/;s/Aug/08/;s/Sep/09/;s/Oct/10/;s/Nov/11/;s/Dec/12/' | head -10
        echo
    fi
}

getWinningTeamLargestDifference() {
    echo "Enter your team number : "
    read temp
    teamName=$(awk -F, 'NR=='$((temp+1))' {print $1}' $1) # 팀 이름을 얻음

    # 가장 큰 점수 차이를 가진 경기 승리 찾기
    awk -F, -v team="$teamName" '
    BEGIN {maxDiff = 0}
    $3 == team {
        diff = $5 - $6
        if (diff > maxDiff) {
            maxDiff = diff
            maxDiffGames = $1"\n"$3" "$5" vs "$6" "$4"\n\n"
        } else if (diff == maxDiff) {
            maxDiffGames = maxDiffGames $1"\n"$3" "$5" vs "$6" "$4"\n\n"
        }
    }
    END {print maxDiffGames}' $2
}

if [ "$#" -ne 3 ]; then
    echo "usage: $0 file1 file2 file3"
    exit 1
fi

teamsFile=$1
playersFile=$2
matchesFile=$3

echo ";;;**OSS1 - Project1 ;;;**"
echo
echo "; StudentID : 12191882 ;"
echo
echo "; Name : DoHwan Kim ;"
echo

while true; do
    echo "[MENU]"
    echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
    echo "2. Get the team data to enter a league position in teams.csv"
    echo "3. Get the Top-3 Attendance matches in matches.csv"
    echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
    echo "5. Get the modified format of date_GMT in matches.csv"
    echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
    echo "7. Exit"
    echo
    read -p "Enter tour CHOICE (1~7) : " choice

    case $choice in
        1) getSonData $playersFile ;;
        2) getTeamData $teamsFile ;;
        3) getTop3AttendanceMatches $matchesFile;;
        4) getTeamLeaguePositionAndTopScorer $teamsFile $playersFile ;;
        5) getModifiedDateFormat $matchesFile;;
        6) getWinningTeamLargestDifference $teamsFile $matchesFile;;
        7) echo "Bye!"; break;;
    esac
done
