load 'calculus/lib/calculus.rb'

def parse_tex_file filename
  #create .odt from .docx
  convert_docx_to_odt = IO.popen(["soffice", "--headless", "--convert-to", "odt", filename])
  convert_docx_to_odt.close

  # get name without .docx
  name = filename.scan(/(.+?).docx/)
  odt_file = name[0][0] + ".odt"
  tex_file = name[0][0] + ".tex"

  #create .tex from .odt
  convert_odt_to_tex = IO.popen(["w2l", odt_file, tex_file])
  convert_odt_to_tex.close

  #create array with formules
  tex_text = IO.read(tex_file)
  tex_text.gsub!(/\s+/, "")
  formules = []
  formules << tex_text.scan(/\$(.*?)\$/)
  formules << tex_text.scan(/{equation\*}(.*?){equation\*}/)
end

# formules = parse_tex_file '4.docx'

# formules.each do |str|
#   puts str
# end

Calculus::Expression.new("t/coprod_{i}^{t}{t}=p\\int _{q}^{7}{p}\\ast 67+r", :parse => false).to_png
