# Read file, edit/cleanup data, write file
# Tested in Python 2.7
# I used this script to convert data to be imported in SQL Server
# The CSV files are read, line by line and relevant data is
# converted and written to another txt file.
#
# You can contact me by e-mail at floris@entermi.nl.
#
# Last updated 14 December, 2017.
#
# Floris van Enter
# http://entermi.nl

readFile  = open('./source.csv','r')
writeFile = open('./destination.txt','w')

# Read every line and do something with it
line = readFile.readline()
while line:
    # CSV means comma seperated. Fill in here a way to split on specific character
    contents = line.split(',')

    # read the 7th and 9th column in the line and cleanup the data
    #   removed all quotes ' & "
    #   removed all brackets () and []
    #   strip() to remove whitespaces in front and at the end
    #   Start the string from position 4, skip the first three characters with [3:]

    name = contents[7].replace('"','').replace("'","").replace('[','').replace(']','').strip()[3:] + " (" + type + ")"
    desc = contents[9].replace('"','').replace("'","").strip()

    query = 'DB::statement("INSERT INTO `table` (`name`, `description`, `created_at`, `updated_at`) VALUES '
    query += "('" + name + "', '" + desc + "', now(), now())"
    query += '");'

    # write query and read next line
    writeFile.write(query + "\n")
    line = readFile.readline()

readFile.close()
writeFile.close()