require 'csv'

# git reset --hard;git clean -fd;reset;ruby ~/docs-helpers/page-move.rb ~/docs-helpers/files_to_move.csv

files_to_delete = []

CSV.foreach(ARGV[0], headers: true, col_sep: ", ") do |row|
  new_path = row["new_path"]
  old_path = row["old_path"]

  # delete file if new=remove
  if new_path == "remove"
    files_to_delete.append("#{old_path}.md")
    next
  end

  # translated docs may lag behind en docs
  # create placeholder page for pages missing from translated set
  if old_path == "placeholder"
    %x[ mkdir -p #{new_path.split("/")[0..-2].join("/")} ]
    File.open("#{new_path}.md", "w") do |f|     
      f.write("PLACEHOLDER: TODO COPY CONTENTS")   
    end
    
    next
  end

  # skip if new=old
  if new_path == old_path
    next
  end

  # skip if old doesn't exist
  # possible duplicate
  if !File.exist?("#{old_path}.md")
    puts "File not found/possible duplicate: #{old_path}.md"
    next
  end

  # move file
  %x[ mkdir -p #{new_path.split("/")[0..-2].join("/")} ]
  %x[ mv #{old_path}.md #{new_path}.md ]

  update_links(old_path, new_path)

=begin
  # update sidebar
  if old_path.start_with?("docs/")
    old_path = old_path.sub("docs/", "")
    new_path = new_path.sub("docs/", "")
    sidebar_file = "sidebars.js"

    # create redirect block for moved file
    redirect_block = "{
  to: '/#{new_path}',
  from: '/#{old_path}'
},"
    redirects.append(redirect_block)

  # versioned_docs/version-XYZ
  else
    version = old_path[/version-[^\/]+/]
    version_number = old_path[/version-[^\/]+/].sub("version-","")
    old_path = old_path.sub(/versioned_docs\/version-[^\/]+\//, "")
    new_path = new_path.sub(/versioned_docs\/version-[^\/]+\//, "")
    sidebar_file = "versioned_sidebars/#{version}-sidebars.json"

    # create redirect block for moved file
    redirect_block = "{
  to: '/v#{version_number}/#{new_path}',
  from: '/v#{version_number}/#{old_path}'
},"
    redirects.append(redirect_block)
  end
=end

end

# File.write("new_redirects.txt", redirects.join("\n"))

files_to_delete.each do |file|
  File.delete(file)
end

# remove empty directories
%x[ find . -depth -type d -empty -delete ]

BEGIN {
  def update_links(old_path, new_path)
    pwd = (%x[ pwd ]).chomp
    unversioned_old_path = ""

    if old_path.start_with?("docs/")
      unversioned_old_path = old_path.sub("docs/", "")
      files_with_link = %x[ grep -rl --include \\*.md "#{unversioned_old_path}.md" docs ] + %x[ grep -rl --include \\*.md "#{unversioned_old_path.split("/")[-1]}.md" docs ]
    else
      versioned_path = old_path.split("/")[0..1].join("/")
      unversioned_old_path = old_path.sub(/versioned_docs\/version-[^\/]+\//, "")
      files_with_link = %x[ grep -rl --include \\*.md "#{unversioned_old_path}.md" "#{versioned_path}" ] + %x[ grep -rl --include \\*.md "#{unversioned_old_path.split("/")[-1]}.md" #{versioned_path} ]
    end

    if !files_with_link.empty?
      files_with_link.split.uniq.each do |file|
        if file == "#{new_path}.md"
          next
        end

        file.chomp!
        dirname = file.split("/")[0..-2].join("/")

        links_in_file = %x[ grep -oE "[_:./a-zA-Z0-9+-]*#{unversioned_old_path.split('/')[-1]}\\.md" #{file} ]

        # filter out external links and absolute links to versioned docs
        links_in_file = links_in_file.split.uniq.reject {|link| link.include?("http:/") || link.include?("https:/") || link.include?("www.") || link.include?("versioned_docs/version-") || link.start_with?("/") }

        links_in_file.each do |link|
          # some file have the same filename e.g. pages-for-subheaders/vsphere.md vs reference-guides/cluster-configuration/downstream-cluster-configuration/node-template-configuration/vsphere.md
          # check if filename in link matches moved file's name
          if link.split("/")[-1].sub(".md","") == unversioned_old_path.split("/")[-1]
            full_path_link_in_file = %x[ realpath #{dirname}/#{link}].chomp.sub("#{pwd}/","").sub(".md","")
            # check the link points to the moved file's old path
            if full_path_link_in_file == old_path
              rel_link = %x[ realpath --relative-to=#{dirname} #{new_path}.md ].chomp
              %x[ sed -i "s|#{link}|#{rel_link}|g" #{file} ]
            end
          end
        end
      end
    end

    # update links in moved file
    links_in_moved_file = %x[ grep -oE "[_:./a-zA-Z0-9+-]*\\.md" #{new_path}.md ]

    # filter out external links and absolute links to versioned docs
    internal_links_in_moved_file = links_in_moved_file.split.uniq.reject {|link| link.include?("http:/") || link.include?("https:/") || link.include?("www.") || link.include?("versioned_docs/version-") }

    if !internal_links_in_moved_file.empty?
      internal_links_in_moved_file.each do |link|
        link.sub!("(","")

        # remove (./, (../../, etc to get path
        file_path = link.sub(/[\.\/]*/,"")
        full_path_link_in_file = "#{pwd}/#{old_path.split("/")[0..-2].join("/")}/#{link}"
        full_path_moved_file = "#{pwd}/#{new_path}"
        rel_link = %x[ realpath --relative-to=#{full_path_moved_file.split("/")[0..-2].join("/")} #{full_path_link_in_file}].chomp
        
        # links using [alt test](link) format
        %x[ sed -i "s|\]([./]*#{link}|\](#{rel_link}|g" #{new_path}.md ] # different directory as moved file
        %x[ sed -i "s|\]([./]*#{link.split('/')[-1]}|\](#{rel_link}|g" #{new_path}.md ] # same directory as moved file

        # links using reference-style
        %x[ sed -i "s|\]: [./]*#{link}|\]: #{rel_link}|g" #{new_path}.md ] # different directory as moved file
        %x[ sed -i "s|\]: [./]*#{link.split('/')[-1]}|\]: #{rel_link}|g" #{new_path}.md ] # same directory as moved file
      end
    end
  end
}
