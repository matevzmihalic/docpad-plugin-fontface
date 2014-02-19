module.exports = (testers) ->
    balUtil = require('bal-util')
    {expect} = require('chai')
    _ = require('lodash')
    fs = require('fs')
    buffertools = require('buffertools')

    #same as balUtil.scanlist, except it reads binary files
    scanlist = (path,next) ->
        balUtil.scandir(
            path: path
            readFiles: 'binary'
            ignoreHiddenFiles: true
            next: (err,list) ->
                return next(err,list)
        )
        @

    # Define My Tester
    class MyTester extends testers.RendererTester
        # Test Generation
        config:
            ignore:
                ttf: ->
                    [
                        {start: 64, length: 4}
                        {start: 216, length: 4}
                        {start: 232, length: 16}
                    ]
                woff: (buffer) ->
                    offsets = [
                        {start: 120, length: 4}
                    ]
                    magic1 = new Buffer [0x78, 0x9C, 0x63, 0x60, 0x64, 0x60, 0x60, 0x00]
                    magic2 = new Buffer [0x78, 0x9C, 0x63, 0x60, 0x64, 0x60]
                    start_index = 0
                    while offsets.length is 1
                        index = buffertools.indexOf buffer, magic1, start_index
                        if buffertools.compare(buffer.slice(index + 52, index + 58), magic2) is 0
                            offsets.push {start: index+10, length: 40}
                        else
                            start_index = index
                    offsets

                eot: (buffer) -> 
                    offsets = [
                        {start: 60, length: 4}
                    ]

                    header_offset = 82 
                    header_offset += buffer.readUInt16LE(header_offset) + 4
                    header_offset += buffer.readUInt16LE(header_offset) + 4
                    header_offset += buffer.readUInt16LE(header_offset) + 4
                    header_offset += buffer.readUInt16LE(header_offset) + 4

                    offsets.push {start: header_offset+66, length: 4}
                    offsets.push {start: header_offset+216, length: 8}
                    offsets.push {start: header_offset+232, length: 16}

                    offsets

        testGenerate: ->
            # Prepare
            tester = @

            # Test
            @suite "generate", (suite,test) ->
                test 'action', (done) ->
                    tester.docpad.action 'generate', (err) ->
                        return done(err)

                suite 'results', (suite,test,done) ->
                    # Get actual results
                    scanlist tester.docpadConfig.outPath, (err,outResults) ->
                        return done(err)  if err

                        # Get expected results
                        scanlist tester.config.outExpectedPath, (err,outExpectedResults) ->
                            return done(err)  if err

                            # Prepare
                            outResultsKeys = Object.keys(outResults)
                            outExpectedResultsKeys = Object.keys(outExpectedResults)

                            # Check we have the same files
                            test 'same files', ->
                                outDifferenceKeys = _.difference(outResultsKeys, outExpectedResultsKeys)
                                expect(outDifferenceKeys).to.be.empty

                            # Check the contents of those files match
                            outResultsKeys.forEach (key) ->
                                test "same file content for: #{key}", ->
                                    # Fetch file value
                                    actual = outResults[key]
                                    expected = outExpectedResults[key]

                                    name = key.split('.')
                                    if name[name.length-1] of tester.config.ignore
                                        for ignore in tester.config.ignore[name[name.length-1]](expected)
                                            actual.fill 0, ignore.start, ignore.start+ignore.length
                                            expected.fill 0, ignore.start, ignore.start+ignore.length

                                    # Compare
                                    try
                                        expect(actual).to.eql(expected)
                                    catch err
                                        fs.writeFile '/tmp/actual', actual
                                        fs.writeFile '/tmp/expected', expected
                                        console.log '\nactual:'
                                        console.log actual
                                        console.log '\nexpected:'
                                        console.log expected
                                        console.log ''
                                        throw err

                            # Forward
                            done()

            # Chain
            @