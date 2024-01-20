files_to_ignore = []

if ARGV[2]
  files_to_ignore = File.readlines(ARGV[2]).map(&:chomp)
end

# Remove existing canonical tags
files = %x[ grep --include \\*.md -ril '<link rel="canonical"' ]
files.split.each do |file|
  if files_to_ignore.include?(file)
    next
  end

  contents = File.read(file)

  # Remove line with canonical tag
  new_contents = contents.sub(/  <link rel=\"canonical\".*\n/, "")

  # Remove empty head tags
  aaa = new_contents.sub(/[\n]*<head>[\n]+<\/head>[\n]*/,"\n\n")
  
  File.open(file, "w") {|file| file.puts aaa }
end

# Add a canonical url to all Markdown files in the /docs directory and add the
# same canonical url to the pages in versioned_docs with the same filepath
Dir.glob("#{ARGV[1]}/**/*.md") do |file|

  # e.g. "https://ranchermanager.docs.rancher.com"
  domain = ARGV[0].chomp("/")
  filepath = (file.split("/")[0..-2].join("/") + "/" + file.split("/")[-1].sub(".md","").sub(/^\d+-/, "")).sub("docs/","")
  canonical_url = domain + "/" + filepath

  if !%x[ grep 'slug: /' #{file} ].empty?
    canonical_url = domain
  end

  add_canonical(file, canonical_url)

  # find all files in versioned_docs with the same filepath
  versioned_files = %x[ find versioned_docs -path "*#{file.sub('docs/','')}" ]

  # if there are files with the same filepath in versioned_docs, add the
  # canonical url
  if !versioned_files.empty?
    versioned_files.split.each do |versioned_file|
      if files_to_ignore.include?(versioned_file)
        next
      end

      add_canonical(versioned_file, canonical_url)
    end
  end
end

remaining_files_without_canonical("versioned_docs")

BEGIN {
  def add_canonical(file, canonical_url)
    new_file = []

    File.foreach(file).with_index do |line, line_num|
      if line.strip == "---" && line_num > 0
        canonical_tag = %{---

<head>
  <link rel="canonical" href="#{canonical_url}"/>
</head>
}
        new_file << canonical_tag
      else
        new_file << line
      end
    end

    File.write("#{file}", new_file.join)
    return true
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
