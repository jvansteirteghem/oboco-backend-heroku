wget -O "/tmp/oboco/episodes-v1.json" "https://www.peppercarrot.com/0_sources/episodes-v1.json"

mkdir "/usr/share/oboco/data/Pepper And Carrot (D.Revoy, CC-By)"
mkdir "/tmp/oboco/Pepper And Carrot"

total_episodes=$(jq length "/tmp/oboco/episodes-v1.json")
for ((episode_number = 0; episode_number <= $total_episodes - 1; episode_number = episode_number + 1));
do
	episode=$(jq -r ".[$episode_number]" "/tmp/oboco/episodes-v1.json");
	name=$(jq -r ".name" <<< "$episode");
	episode_name=$(sed s/\-/\ /g <<< "$name");
	episode_name=$(sed s/\ s\ /\'s\ /g <<< "$episode_name");
	episode_name=$(sed s/ep/Episode\ / <<< "$episode_name");
	episode_name=$(sed s/\_/\ \-\ / <<< "$episode_name");
	episode_name_array=($episode_name)
	episode_name="${episode_name_array[@]^}"
	
	mkdir "/tmp/oboco/Pepper And Carrot/${episode_name}"
	
	pages=$(jq -r ".pages" <<< "$episode");
	total_pages=$(jq -r ".total_pages" <<< "$episode");
	page=$(jq -r ".cover" <<< "$pages");
	page_number=0;
	
	wget -O "/tmp/oboco/Pepper And Carrot/${episode_name}/${page_number}.jpg" "https://www.peppercarrot.com/0_sources/${name}/low-res/$page"
	
	page=$(jq -r ".title" <<< "$pages");
	page_number=$((page_number + 1));
	
	wget -O "/tmp/oboco/Pepper And Carrot/${episode_name}/${page_number}.jpg" "https://www.peppercarrot.com/0_sources/${name}/low-res/en_$page"
	
	for ((i = 1; i <= $total_pages - 1; i = i + 1));
	do
		page=$(jq -r ".\"$i\"" <<< "$pages");
		page_number=$((page_number + 1));
		
		wget -O "/tmp/oboco/Pepper And Carrot/${episode_name}/${page_number}.jpg" "https://www.peppercarrot.com/0_sources/${name}/low-res/en_$page"
	done;
	
	page=$(jq -r ".credits" <<< "$pages");
	page_number=$((page_number + 1));
	
	wget -O "/tmp/oboco/Pepper And Carrot/${episode_name}/${page_number}.jpg" "https://www.peppercarrot.com/0_sources/${name}/low-res/en_$page"
	
	zip -r "/usr/share/oboco/data/Pepper And Carrot (D.Revoy, CC-By)/${episode_name}.zip" "/tmp/oboco/Pepper And Carrot/${episode_name}"
done;