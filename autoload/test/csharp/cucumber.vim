if !exists('g:test#csharp#tcucumber#file_pattern')
  let g:test#csharp#cucumber#file_pattern = '\.feature$'
endif

function! test#csharp#cucumber#test_file(file) abort
  return a:file =~? g:test#csharp#cucumber#file_pattern
endfunction

function! test#csharp#cucumber#build_position(type, position) abort
  let file = a:position['file']
  let filename = substitute(substitute(expand('%t:%r'), '/', '.', 'g'), '.\w*.feature', '', '')
  let filepath = fnamemodify(file, ':p:h')
  let project_files = split(glob(filepath . '/*.csproj'), '\n')
  let search_for_csproj = 1

  while len(project_files) == 0 && search_for_csproj
    let filepath_parts = split(filepath, '/') 
    let search_for_csproj = len(filepath_parts) > 1
    let filepath = '/'.join(filepath_parts[0:-2], '/')
    let project_files = split(glob(filepath . '/*.csproj'), '\n')
  endwhile

  if len(project_files) == 0
    throw 'Unable to find .csproj file, a .csproj file is required to make use of the `dotnet test` command.'
  endif

  let project_path = project_files[0]
  let project_name = split(project_path, '/')[-1]
  let project_path = substitute(project_path, project_name, '', '')

  let project_path = project_path . '/bin/debug/' . substitute(project_name, '.csproj', '.dll', '')

  let ns = filename
  let l = getline(1)
  if l =~ '^Feature:\s\w.*'
    let feature_parts = split(split(l, ': ')[-1], ' ')
    let camel_feature_parts = []
    for f in feature_parts
      let camel_feature_parts += [toupper(f[0]), f[1:-1]]
    endfor
    let ns = filename .'.'. join(camel_feature_parts, '') . 'Feature'
  endif
  if a:type == 'nearest'
    let name = s:nearest_test(a:position)
    let scenario_parts = split(split(name, ': ')[-1], ' ')
    let camel_scenario_parts = []
    for f in scenario_parts
      let camel_scenario_parts += [toupper(f[0]), f[1:-1]]
    endfor
    let scenario = ns .'.'. join(camel_scenario_parts, '')

    return [scenario, project_path]
  elseif a:type == 'file'
    return [ns, project_path]
  else
    return ['*', project_path]
  endif
endfunction

function! test#csharp#cucumber#build_args(args) abort
  let filter = ''
  if a:args[0] != '*'
    let filter = a:args[0]
  endif
  let args = [a:args[1], filter]
  let joiner = a:args[0] != '*' ? ' /run:' : ''
  return [join(args, joiner)]
endfunction

function! test#csharp#cucumber#executable() abort
  return 'nunit'
endfunction

function! s:nearest_test(position) abort
  let name = test#base#nearest_test(a:position, g:test#csharp#patterns)
  if !empty(name['test']) 
    return join(name['test'], '.')
  endif
endfunction
