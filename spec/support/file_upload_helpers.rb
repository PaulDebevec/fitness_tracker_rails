module FileUploadHelpers
    def test_image_upload(filename)
        filetype = filename.split('.')[1]
        fixture_file_upload(filename, "image/#{filetype}")
    end
end