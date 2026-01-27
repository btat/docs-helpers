require 'csv'
require 'pathname'

# git reset --hard;git clean -fd;reset;ruby ~/docs-helpers/antora/create_alternate_structure.rb ~/docs-helpers/mapping.csv v2.13 en

version = ARGV[1]
language = ARGV[2]

CSV.foreach(ARGV[0], headers: true, col_sep: ",") do |row|
  puts "row: #{row}"

  p_path = row["product_path"]
  c_path = row["community_path"]
  
  pwd = (%x[ pwd ]).chomp
  p_base_path = "versions/#{version}/modules/#{language}/pages"
  c_base_path = "community-docs/#{version}/modules/#{language}/pages"

  p_file = pwd + "/" + p_base_path + "/" + p_path
  c_file = pwd + "/" + c_base_path + "/" + c_path

  c_dirname = %x[ dirname #{c_file}].chomp
  %x[ mkdir -p #{c_dirname}]

#   relative_path = %x[ realpath --relative-to=#{c_dirname} #{p_file} ].chomp

  file_p = Pathname.new(p_file)
  file_c = Pathname.new(c_dirname)
  relative_path = file_p.relative_path_from(file_c)

  

  puts "c file: #{c_file}"
  puts "p file: #{p_file}"
  puts file_p.relative_path_from(file_c)
  %x[ ln -s #{relative_path} #{c_base_path + "/" + c_path}]
  puts " "
end