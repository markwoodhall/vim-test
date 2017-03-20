if !exists('g:test#cs#dotnettest#file_pattern')
  let g:test#cs#dotnettest#file_pattern = '\v^.*[Tt]ests\.cs$'
endif

function! test#cs#dotnettest#test_file(file) abort
  return a:file =~? g:test#cs#dotnettest#file_pattern
endfunction

function! test#cs#dotnettest#build_position(type, position) abort
  let file = a:position['file']
  let filename = fnamemodify(file, ':t:r')
  let filepath = fnamemodify(file, ':.:h')
  let projectPath = split(filepath, '/')[0]
  let projectPath = projectPath . '/' . projectPath . '.csproj'

  if a:type == 'nearest'
    let name = s:nearest_test(a:position)
    if !empty(name)
      return [name, projectPath]
    else
      return [filename, projectPath]
    endif
  elseif a:type == 'file'
    return [filename, projectPath]
  else
    return ['*', projectPath]
  endif
endfunction

function! test#cs#dotnettest#build_args(args) abort
  let filter = ''
  if a:args[0] != '*'
    let filter = ' --filter FullyQualifiedName\~'.a:args[0]
  endif
  let args = ['test ', a:args[1], filter]
  return [join(args, "")]
endfunction

function! test#cs#dotnettest#executable() abort
  return 'dotnet'
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#cs#patterns)
  return join(name['namespace'] + name['test'], '.')
endfunction
