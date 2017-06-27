require 'tmpdir'
require 'digest'

# Renders expression to PNG image using <tt>latex</tt> and
# <tt>dvipng</tt>
# returns array to images
def formula_to_png(formulas, background = 'White', density = 700)
  arr_images = []
  temp_path = Dir.mktmpdir
  Dir.chdir(temp_path) do
    formulas.each do |formula|
      rand_word = ('a'..'z').to_a.shuffle.join
      sha1 = Digest::SHA1.hexdigest rand_word
      File.open("#{sha1}.tex", 'w') do |f|
        f.write("\\documentclass{article}\n" +
                 "\\usepackage{amsmath,amssymb}\n" +
                 "\\begin{document}\n" +
                 "\\thispagestyle{empty}\n" +
                 "$$ #{formula} $$\n" +
                 "\\end{document}\n")
      end
      `latex -interaction=nonstopmode #{sha1}.tex && dvipng -q -T tight -bg #{background} -D #{density.to_i} -o #{sha1}.png #{sha1}.dvi`
      File.delete("#{sha1}.tex") if File.exists?("#{sha1}.tex")
      File.delete("#{sha1}.aux") if File.exists?("#{sha1}.aux")
      File.delete("#{sha1}.dvi") if File.exists?("#{sha1}.dvi")
      File.delete("#{sha1}.log") if File.exists?("#{sha1}.log")
      arr_images << File.join(temp_path, "#{sha1}.png") if $?.exitstatus.zero?
    end
  end
  return arr_images
end

def parse_tex_file input_file_path, output_file_path
  arr_path_filename = File.split(input_file_path)
  outdir = arr_path_filename[0]
  docx_file = arr_path_filename[1]

  #create .odt from .docx
  `soffice --headless --convert-to odt --outdir #{outdir} #{docx_file}`

  # alternative
  # convert_docx_to_odt = IO.popen(["soffice", "--headless", "--convert-to", "odt", "--outdir", outdir, docx_file])
  # convert_docx_to_odt.close

  # get name without .docx
  name = docx_file.scan(/(.+?)\.docx/)

  # create path to odt and tex files
  odt_path = File.expand_path(name[0][0] + ".odt", outdir)
  tex_path = File.expand_path(name[0][0] + ".tex", outdir)

  # create .tex from .odt
  `w2l #{odt_path} #{tex_path}`

  # alternative
  # convert_odt_to_tex = IO.popen(["w2l", odt_path, tex_path])
  # convert_odt_to_tex.close

  # create array with formulas
  tex_text = File.read(tex_path)
  tex_text.gsub!(/\s+/, "")
  formulas = []
  arr1 = tex_text.scan(/\$(.*?)\$/im)
  unless arr1.empty?
    arr1.each do |level_1|
      level_1.each do |level_2|
        formulas << level_2
      end
    end
  end
  arr2 = tex_text.scan(/\\begin{equation\*}(.+?)\\end{equation\*}/im)
  unless arr2.empty?
    arr2.each do |level_1|
      level_1.each do |level_2|
        formulas << level_2
      end
    end
  end
  # --CHECK--
  # formulas.each do |str|
  #   puts str
  # end
  # --CHECK--

  images = formula_to_png(formulas)

  result = []
  images.length.times do |i|
    result << {img_path: images[i], text: formulas[i]}
  end

  puts result


  # delete .odt and .tex files
  File.delete(odt_path) if File.exists?(odt_path)
  File.delete(tex_path) if File.exists?(tex_path)
end

formulas = parse_tex_file '/home/sergei/Programs/Work/plagiarizm/formula-parser/4.docx', '/home/sergei/Programs/Work/plagiarizm/formula-parser/output.docx'


