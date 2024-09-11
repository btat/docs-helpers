files_with_link = %x[ grep -rlE --include \\*.adoc "xref:[^#]" ].chomp
pwd = (%x[ pwd ]).chomp

files_with_link.split.uniq.each do |file|
  internal_links_in_file = %x[ grep -oE "xref:[^#][^(#|\[]*" #{file} ].chomp
  file_abs_path = pwd + "/" + file
  file_dirname = %x[ dirname #{file_abs_path} ].chomp
  internal_links_in_file.split.uniq.each do |link|
    link_abs_path = %x[ realpath #{file_dirname + "/" + link.sub("xref:","")} ].chomp
    new_link = link_abs_path.sub(pwd + "/","")

    %x[ sed -i "s|#{link.sub("xref:","")}|#{new_link}|g" #{file} ]
  end
end