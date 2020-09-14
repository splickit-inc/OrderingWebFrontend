require "theme"

class SkinsController < ApplicationController
  skip_before_action :set_user_instance, :setup_skin_id, :sign_in_punchh

  def service
    theme = Theme.new(skins_params)
    theme.generate
    theme.upload("staging")

    respond_to do |format|
      format.json { render json: { skin: { name: "preview", url: "preview.splickit.io" } }, status: :ok }
    end
  rescue StandardError => e
    respond_to do |format|
      format.json { render json: { error: e }, status: :unprocessable_entity }
    end
  end

  private

  def skins_params
    params.permit!.merge!(name: "preview", aws_folder: "com.splickit.preview",
                          theme_directory: Rails.root.join("public", "theme", "brands", "preview"))
  end
end