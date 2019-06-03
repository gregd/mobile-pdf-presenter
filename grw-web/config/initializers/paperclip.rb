Paperclip.options[:content_type_mappings] = {
  log: "text/plain"
}
Paperclip::Attachment.default_options.update(
  {
    url: "/system/:class/:id_partition/:attachment/:hash.:extension",
    hash_secret: Rails.application.secrets.paperclip_key
  })
