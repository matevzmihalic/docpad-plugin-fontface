# Export Plugin
module.exports = (BasePlugin) ->
    fs = require('fs')
    mkdirp = require('mkdirp')
    
    # Define Plugin
    class FontFacePlugin extends BasePlugin
        # Plugin name
        name: 'fontface'

        config:
            fontface:
                output: ['ttf', 'svg', 'eot', 'woff', 'css']

        renderTTF: (file, write=true) ->
            docpad.log 'debug', 'Rendering ttf'
            
            svg2ttf = require('svg2ttf')
            ttf = svg2ttf file.buffer.toString('utf-8'), {}
            if write
                fs.writeFileSync file.attributes.outPath + '.ttf', new Buffer(ttf.buffer)

            new Buffer ttf.buffer

        renderWOFF: (file) ->
            docpad.log 'debug', 'Rendering woff'

            ttf2woff = require('ttf2woff')
            woff = ttf2woff new Uint8Array(@renderTTF(file, false)), {}
            fs.writeFileSync file.attributes.outPath + '.woff', new Buffer(woff.buffer)

        renderEOT: (file) ->
            docpad.log 'debug', 'Rendering eot'

            ttf2eot = require('ttf2eot')
            eot = ttf2eot new Uint8Array(@renderTTF(file, false)), {}
            fs.writeFileSync file.attributes.outPath + '.eot', new Buffer(eot.buffer)

        renderSVG: (file) ->
            docpad.log 'debug', 'Rendering svg'

            fs.writeFileSync file.attributes.outPath + '.svg', file.buffer

        renderCSS: (file) ->
            docpad.log 'debug', 'Rendering css'

            css = ""
            if 'eot' in @config.fontface.output
                css += "\n    src: url('#{ file.attributes.basename }.eot');\n    src: url('#{ file.attributes.basename }.eot?#iefix') format('embedded-opentype')"
            if 'woff' in @config.fontface.output
                css += ',\n' if css.length
                css += "    url('#{ file.attributes.basename }.woff') format('woff')"
            if 'ttf' in @config.fontface.output
                css += ',\n' if css.length
                css += "    url('#{ file.attributes.basename }.ttf') format('truetype')"
            if 'svg' in @config.fontface.output
                css += ',\n' if css.length
                css += "    url('#{ file.attributes.basename }.svg##{file.attributes.basename}') format('svg')"
            
            css = """
            @font-face {
                font-family: '#{ file.attributes.basename }';
                font-weight: normal;
                font-style: normal;
            """ + css + ";\n}"

            fs.writeFileSync file.attributes.outPath + '.css', css
            

        # Render
        render: (opts) ->
            # Prepare
            {inExtension,outExtension,file} = opts

            # Converts svg file to @font-face files if it is using the convention .(ff|fontface).svg
            if inExtension in ['svg'] and outExtension in ['ff','fontface']
                docpad.log "info", file.attributes.outDirPath
                mkdirp.sync file.attributes.outDirPath
                fs.unlink opts.file.outPath + '.*', =>
                    for extension in @config.fontface.output
                        @['render' + extension.toUpperCase()](opts.file)

            # Done
            return