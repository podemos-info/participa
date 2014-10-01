# https://github.com/jim/carmen
# By default, in Spain, Carmen organizes the data in the following way: 
#   Spain > Autonomous Community > Province
# So for instance
#   Spain > Andalucía > Sevilla
# The thing is we don't want the intermediate step on CCAA, so 
# we remove them and only put the provinces in Carmen for Spain. 
Carmen.clear_data_paths
Carmen.append_data_path Rails.root.join('db', 'iso_data', 'base').to_s
#Carmen.append_data_path Rails.root.join('db', 'iso_data', 'base', 'world').to_s
#Carmen.append_data_path Rails.root.join('db', 'iso_data', 'overlay').to_s
#Carmen.append_data_path Rails.root.join('db', 'iso_data', 'overlay', 'world').to_s
