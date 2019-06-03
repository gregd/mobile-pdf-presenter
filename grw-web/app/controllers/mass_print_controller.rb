class MassPrintController < ClientController
  include PermControl

  def index
    #label = "Nadawca:\n<b>example.com</b>\nAddress City"
    @print = MassPrint.new
    @print.person_search_id = params[:person_search_id]
    @print.org_unit_search_id = params[:org_unit_search_id]
  end

  def pdf
    @print = MassPrint.new(print_params)
    unless @print.valid?
      render :index
      return
    end

    cols = 3
    rows = 8

    Prawn::Labels.types = {
      "Emerson024" => {
        "paper_size"    => "A4",
        "columns"       => cols,
        "rows"          => rows,
        "top_margin"    => 3,
        "bottom_margin" => 3,
        "left_margin"   => 3,
        "right_margin"  => 3,
        "column_gutter" => 0,
        "row_gutter"    => 0 }}

    if @print.any_text?
      labels = 1.upto(cols * rows).map {|i| @print.text }
    else
      labels = @print.receivers.map {|p,ou,a| <<~LABEL }
        #{ p.first_name } #{ p.last_name }
        #{ ou.name }
        #{ a.street } #{ a.house_nr } #{ a.flat_nr ? " / " + a.flat_nr : "" }
        #{ a.zipcode } #{ a.city }
        #{ a.country }
      LABEL
    end

    font_dir = File.join(Rails.root, "data", "fonts", "open_sans")

    pdf = Prawn::Labels.render(labels, type: "Emerson024") do |pdf, name|
      pdf.font_families.update(
        "Open Sans" => {
          :bold_italic        => "#{font_dir}/OpenSans-BoldItalic.ttf",
          :bold               => "#{font_dir}/OpenSans-Bold.ttf",
          :extra_bold_italic  => "#{font_dir}/OpenSans-ExtraBoldItalic.ttf",
          :extra_bold         => "#{font_dir}/OpenSans-ExtraBold.ttf",
          :italic             => "#{font_dir}/OpenSans-Italic.ttf",
          :light_italic       => "#{font_dir}/OpenSans-LightItalic.ttf",
          :light              => "#{font_dir}/OpenSans-Light.ttf",
          :normal             => "#{font_dir}/OpenSans-Regular.ttf",
          :semi_bold_italic   => "#{font_dir}/OpenSans-SemiboldItalic.ttf",
          :semi_bold          => "#{font_dir}/OpenSans-Semibold.ttf",
        })

      # pdf.stroke_bounds
      pdf.font "Open Sans"
      pdf.indent(10) do
        pdf.text name, inline_format: true, valign: :center
      end
    end

    send_data(pdf, filename: "mass_print.pdf", type: "application/pdf", disposition: "inline")
  end

  private

  def print_params
    params.require(:mass_print).permit(:text, :person_search_id, :org_unit_search_id)
  end

end
