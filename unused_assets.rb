require 'json'

# ARGV[0] = asset directory (include trailing slash)
# ARGV[1] = search directory (include trailing slash)
# ARGV[2] = "delete" to also remove unused asset file

asset_dir =  ARGV[0]
search_dir = ARGV[1]

results = {"Used" => [], "Unused" => []}

Dir.glob("#{asset_dir.chomp("/")}/**/*.*") do |asset_full_path|
  asset = asset_full_path.sub(asset_dir,"")
  if !%x[ grep -ri #{asset} #{search_dir} ].empty?
    results["Used"] << asset
  else
    results["Unused"] << asset
    if ARGV[2] && ARGV[2].downcase == "delete"
      File.delete(asset_full_path)
    end
  end
end

File.write("unused_assets.json", JSON.pretty_generate(results))
