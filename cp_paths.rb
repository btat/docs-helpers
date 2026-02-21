files = %x[ grep --include *.adoc -Rl "community-path" versions/v2.12/modules/en/pages ]
files = files.split

files.each do |file|
  c_path = %x[ grep -Po ":community-path: \\K.*\\$" #{file}].strip
  p_path = %x[ grep -Po ":product-path: \\K.*\\$" #{file}].strip
  
  %x[ sed -i "s@:product-path: #{p_path}@:product-path: #{p_path}.adoc@" #{file} ]
  %x[ sed -i "s@:community-path: #{c_path}@:community-path: #{c_path}.adoc@" #{file} ]
end
