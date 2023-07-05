# Check all Markdown files in the /docs dir. If the file doesn't have a
# canonical url, add it and add it to the versioned pages with the same filepath
Dir.glob('docs/**/*.md') do |file|
  domain = "https://ranchermanager.docs.rancher.com"
  canonical_url = (domain + file.sub("docs/","/").sub(".md","")).sub("/","\\/").sub(".","\\.")

  if !%x[ grep 'slug: /' #{file} ].empty?
    canonical_url = domain
  end

  # If adding canonical url, find all versioned instances of file with the same
  # path and add it to them too
  if add_canonical(file, canonical_url)
    versioned_files = %x[ find versioned_docs -path "*#{file.sub('docs/','')}" ]

    if !versioned_files.empty?
      versioned_files.split.each do |versioned_file|
        add_canonical(versioned_file, canonical_url)
      end
    end
  end
end

remaining_files_without_canonical("versioned_docs")

BEGIN {
  def add_canonical(file, canonical_url)
    current_file = %x[ grep '<link rel="canonical"' #{file} ]

    if !current_file.empty?
      return false
    elsif
      File.foreach(file).with_index do |line, line_num|
        line = line.strip!
        if line == "---" && line_num > 0
          canonical_tag = "---\\n\\n<head>\\n  <link rel=\"canonical\" href=\"#{canonical_url}\"\\/>\\n<\\/head>"
          %x[ sed -i '#{line_num+1}s|---|#{canonical_tag}|' #{file} ]
        end
      end
    end

    return true
  end

  def remaining_files_without_canonical(dir)
    files_without_canonical = []
    Dir.glob("#{dir}/**/*.md") do |file|
      current_file = %x[ grep '<link rel="canonical"' #{file} ]
      if current_file.empty?
        files_without_canonical += [file]
      end
    end

    File.write("files_without_canonical.txt", files_without_canonical.join("\n"))
  end
}
