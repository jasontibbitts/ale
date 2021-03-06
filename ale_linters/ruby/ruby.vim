" Author: Brandon Roehl - https://github.com/BrandonRoehl
" Description: Ruby MRI for Ruby files

function! ale_linters#ruby#ruby#Handle(buffer, lines) abort
    " Matches patterns line the following:
    "
    " test.rb:3: warning: parentheses after method name is interpreted as an argument list, not a decomposed argument
    " test.rb:8: syntax error, unexpected keyword_end, expecting end-of-input
    let l:pattern = '\v^.+:(\d+): (warning: )?(.+)$'
    let l:column = '\v^(\s+)\^$'
    let l:output = []

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)
        if len(l:match) == 0
            let l:match = matchlist(l:line, l:column)
            if len(l:match) != 0
                let l:output[len(l:output) - 1]['col'] = len(l:match[1])
            endif
        else
            call add(l:output, {
            \   'lnum': l:match[1] + 0,
            \   'col': 0,
            \   'text': l:match[2] . l:match[3],
            \   'type': empty(l:match[2]) ? 'E' : 'W',
            \})
        endif
    endfor

    return l:output
endfunction

call ale#linter#Define('ruby', {
\   'name': 'ruby',
\   'executable': 'ruby',
\   'output_stream': 'stderr',
\   'command': 'ruby -w -c -T1 %t',
\   'callback': 'ale_linters#ruby#ruby#Handle',
\})
