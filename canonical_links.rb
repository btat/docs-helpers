files_to_ignore = []

if ARGV[2]
  files_to_ignore = File.readlines(ARGV[2]).map(&:chomp)
end

# Remove existing canonical tags
# files_to_clear = %x[ grep -ril '<link rel="canonical"' --include \\*.md #{ARGV[1]}]
# versioned_files_to_clear = %x[ find versioned_docs -path "*#{ARGV[1].sub('docs/','')}" ]
# files_to_clear = files_to_clear + versioned_files_to_clear

# files_to_clear.split.each do |file|
#   if files_to_ignore.include?(file)
#     next
#   end

#   contents = File.read(file)

#   # Remove line with canonical tag
#   new_contents = contents.sub(/  <link rel=\"canonical\".*\n/, "")

#   # Remove empty head tags
#   final_contents = new_contents.sub(/[\n]*<head>[\n]+<\/head>[\n]*/,"\n\n")
  
#   File.open(file, "w") {|file| file.puts final_contents }
# end

# Add a canonical url to all Markdown files in the /docs directory and add the
# same canonical url to the pages in versioned_docs with the same filepath
Dir.glob(["#{ARGV[1].chomp("/")}/**/*.md", "#{ARGV[1].chomp("/")}/**/*.mdx"]) do |file|
  # e.g. "https://ranchermanager.docs.rancher.com"
  domain = ARGV[0].chomp("/")
  puts "111 #{file}"
  filepath = (file.split("/")[0..-2].join("/") + "/" + file.split("/")[-1].sub(".mdx","").sub(".md","").sub(/^\d+-/, "")).sub("docs/","")
  puts "  222 filepath = #{filepath}"
  # Check for cases where the file is a "category" file and has the same name as the directory it's in.
  # E.g. "docs/how-to-guides/new-user-guides/new-user-guides"
  filepath_split = filepath.split("/")
  if filepath_split.length >= 2 && filepath_split[-1] == filepath_split[-2]
    # Drop the repeated segment
    filepath = filepath.split("/")[0..-2].join("/")
    puts "    333 filepath=#{filepath}"
  end

  canonical_url = domain + "/" + filepath

  if !%x[ grep 'slug: /' #{file} ].empty?
    canonical_url = domain
  end

  existing_canonical = false

  if !%x[ grep 'rel="canonical"' #{file} ].empty?
    existing_canonical = true
  end

  add_canonical(file, canonical_url, existing_canonical)

  # find all files in versioned_docs with the same filepath
  versioned_files = []
  if filepath_split.length > 2
    versioned_files = %x[ find versioned_docs -path "*#{file.sub('docs/','')}" ]
  else
    # top-level files. e.g. "docs/rancher-manager.md"
    versioned_files = %x[ find versioned_docs -path "*/#{file.sub('docs/','')}" ]
  end

  # if there are files with the same filepath in versioned_docs, add the
  # canonical url
  if !versioned_files.empty?
    versioned_files.split.each do |versioned_file|
      if files_to_ignore.include?(versioned_file)
        next
      end

      existing_canonical = false

      if !%x[ grep 'rel="canonical"' #{versioned_file} ].empty?
        existing_canonical = true
      end

      add_canonical(versioned_file, canonical_url, existing_canonical)
    end
  end
end

remaining_files_without_canonical("versioned_docs")

BEGIN {
  def add_canonical(file, canonical_url, existing_canonical)
    new_file = []
    canonical_added = false

    File.foreach(file).with_index do |line, line_num|
      if !canonical_added
        if line.strip.include?('rel="canonical"')
          canonical_tag = %{  <link rel="canonical" href="#{canonical_url}"/>
}
          new_file << canonical_tag
          canonical_added = true
        elsif line.strip == "---" && line_num > 0 && !existing_canonical
          canonical_tag = %{---

<head>
  <link rel="canonical" href="#{canonical_url}"/>
</head>
}
          canonical_added = true
          new_file << canonical_tag
        else
          new_file << line
        end
      else
        new_file << line
      end
    end

    File.write("#{file}", new_file.join)
  end

  def remaining_files_without_canonical(dir)
    files_without_canonical = []
    Dir.glob("#{dir}/**/*.md") do |file|
      current_file = %x[ grep '<link rel="canonical"' #{file} ]
      if current_file.empty?
        files_without_canonical << file
      end
    end

    File.write("files_without_canonical.txt", files_without_canonical.join("\n"))
  end
}
