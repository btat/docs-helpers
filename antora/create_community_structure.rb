require 'csv'
require 'pathname'

# git reset --hard;git clean -fd;reset;ruby ~/docs-helpers/antora/create_community_structure.rb ~/docs-helpers/mapping.csv v2.13 en

version = ARGV[1]
language = ARGV[2]

pwd = (%x[ pwd ]).chomp
p_base_path = "versions/#{version}/modules/#{language}/pages"
c_base_path = "community-docs/#{version}/modules/#{language}/pages"

CSV.foreach(ARGV[0], headers: true, col_sep: ",") do |row|
  p_path = row["product_path"]
  c_path = row["community_path"]
  
  # Product-exclusive file. No action needed.
  if c_path == nil
    next
  end

  c_file = pwd + "/" + c_base_path + "/" + c_path
  c_dirname = %x[ dirname #{c_file}].chomp
  c_filename = %x[ basename #{c_file}].chomp
  c_parentdir = %x[ basename #{c_dirname}].chomp

  # Files that have the same name as its parent folder are index files. Rename to index.
  if c_filename == c_parentdir
    new_path = c_path.split("/")
    new_path[-1] = "index"
    new_path = new_path.join("/")
    c_file = pwd + "/" + c_base_path + "/" + new_path
  end

  if !Dir.exist?(c_dirname)
    %x[ mkdir -p #{c_dirname}]
  end

  # Community-exclusive file. Create placeholder file.
  if p_path == nil
    %x[ echo "TODO - CONVERT FILE" > #{c_file}.adoc]
  # Common file between Product and Community. Create symlink.
  else
    p_file = pwd + "/" + p_base_path + "/" + p_path + ".adoc"

    if !File.exist?(p_file)
      puts "Skip symlink. Product file not found: #{p_file}"
      next
    end

    file_p = Pathname.new(p_file)
    file_c = Pathname.new(c_dirname)
    
    relative_path = file_p.relative_path_from(file_c)
    %x[ ln -s #{relative_path} #{c_base_path + "/" + c_path}.adoc]
  end  
end