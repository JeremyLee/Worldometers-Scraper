function Get-Charts([string]$url) {
    $originalProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    $r = [regex]::new('Highcharts.chart\(''(?<ChartName>[a-zA-Z0-9-]+)'', (?<Data>{[^{}]*(?>(?>(?''open''{)[^{}]*)+(?>(?''-open''})[^{}]*)+)+(?(open)(?!))})', [System.Text.RegularExpressions.RegexOptions]::Compiled -bor [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    # We need to replace functions with a filler value so they don't confuse the JSON parser.
    $functionMatch = [regex]::new('function\s*\([a-zA-Z0-9_, \r\n]*\)\s*{[^{}]*(?>(?>(?''open''{)[^{}]*)*(?>(?''-open''})[^{}]*)*)+(?(open)(?!))};?', [System.Text.RegularExpressions.RegexOptions]::Compiled -bor [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    # Regex to replace trailing commas, as Powershell's JSON parser dislikes them.
    $trailingComma = [regex]::new(',(?=\s*[\])}])', [System.Text.RegularExpressions.RegexOptions]::Compiled -bor [System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

    

    $text = Invoke-WebRequest -UseBasicParsing -Uri $url
    $ms = $r.Matches($text)
    $results = @{}
    foreach ($m in $ms) {
        $chartName = $m.Groups['ChartName'].Value
        $parsedObject = $trailingComma.Replace($functionMatch.Replace($m.Groups['Data'].Value, 0), "") | ConvertFrom-Json
        $keys = $parsedobject.xAxis.categories
        for ($si = 0; $si -lt $parsedobject.series.Count; $si++) {
            $completeSeriesName = $chartName + '.' + $parsedObject.series[$si].name
            $values = $parsedobject.series[$si].data
            if ($keys.Count -ne $values.Count) {
                Write-Error "Chart $chartName has mismatching legend and series counts."
            }
            $chartResults = @{}
            for ($i = 0; $i -lt $keys.Count; $i++) {
                $chartResults[$keys[$i]] = $values[$i]
            }
            $results[$completeSeriesName] = $chartResults 
        }
    }
    $ProgressPreference = $originalProgress
    return $results
}

$states = @{
    'California'                   = 'https://www.worldometers.info/coronavirus/usa/California'
    'New York'                     = 'https://www.worldometers.info/coronavirus/usa/New-York'
    'Florida'                      = 'https://www.worldometers.info/coronavirus/usa/Florida'
    'Texas'                        = 'https://www.worldometers.info/coronavirus/usa/Texas'
    'New Jersey'                   = 'https://www.worldometers.info/coronavirus/usa/New-Jersey'
    'Illinois'                     = 'https://www.worldometers.info/coronavirus/usa/Illinois'
    'Georgia'                      = 'https://www.worldometers.info/coronavirus/usa/Georgia'
    'Arizona'                      = 'https://www.worldometers.info/coronavirus/usa/Arizona'
    'Massachusetts'                = 'https://www.worldometers.info/coronavirus/usa/Massachusetts'
    'North Carolina'               = 'https://www.worldometers.info/coronavirus/usa/North-Carolina'
    'Pennsylvania'                 = 'https://www.worldometers.info/coronavirus/usa/Pennsylvania'
    'Louisiana'                    = 'https://www.worldometers.info/coronavirus/usa/Louisiana'
    'Tennessee'                    = 'https://www.worldometers.info/coronavirus/usa/Tennessee'
    'Michigan'                     = 'https://www.worldometers.info/coronavirus/usa/Michigan'
    'Virginia'                     = 'https://www.worldometers.info/coronavirus/usa/Virginia'
    'Ohio'                         = 'https://www.worldometers.info/coronavirus/usa/Ohio'
    'Maryland'                     = 'https://www.worldometers.info/coronavirus/usa/Maryland'
    'South Carolina'               = 'https://www.worldometers.info/coronavirus/usa/South-Carolina'
    'Alabama'                      = 'https://www.worldometers.info/coronavirus/usa/Alabama'
    'Indiana'                      = 'https://www.worldometers.info/coronavirus/usa/Indiana'
    'Washington'                   = 'https://www.worldometers.info/coronavirus/usa/Washington'
    'Mississippi'                  = 'https://www.worldometers.info/coronavirus/usa/Mississippi'
    'Minnesota'                    = 'https://www.worldometers.info/coronavirus/usa/Minnesota'
    'Connecticut'                  = 'https://www.worldometers.info/coronavirus/usa/Connecticut'
    'Wisconsin'                    = 'https://www.worldometers.info/coronavirus/usa/Wisconsin'
    'Colorado'                     = 'https://www.worldometers.info/coronavirus/usa/Colorado'
    'Missouri'                     = 'https://www.worldometers.info/coronavirus/usa/Missouri'
    'Nevada'                       = 'https://www.worldometers.info/coronavirus/usa/Nevada'
    'Iowa'                         = 'https://www.worldometers.info/coronavirus/usa/Iowa'
    'Arkansas'                     = 'https://www.worldometers.info/coronavirus/usa/Arkansas'
    'Utah'                         = 'https://www.worldometers.info/coronavirus/usa/Utah'
    'Oklahoma'                     = 'https://www.worldometers.info/coronavirus/usa/Oklahoma'
    'Kentucky'                     = 'https://www.worldometers.info/coronavirus/usa/Kentucky'
    'Kansas'                       = 'https://www.worldometers.info/coronavirus/usa/Kansas'
    'Nebraska'                     = 'https://www.worldometers.info/coronavirus/usa/Nebraska'
    'New Mexico'                   = 'https://www.worldometers.info/coronavirus/usa/New-Mexico'
    'Rhode Island'                 = 'https://www.worldometers.info/coronavirus/usa/Rhode-Island'
    'Idaho'                        = 'https://www.worldometers.info/coronavirus/usa/Idaho'
    'Oregon'                       = 'https://www.worldometers.info/coronavirus/usa/Oregon'
    'Delaware'                     = 'https://www.worldometers.info/coronavirus/usa/Delaware'
    'District Of Columbia'         = 'https://www.worldometers.info/coronavirus/usa/District-Of-Columbia'
    'South Dakota'                 = 'https://www.worldometers.info/coronavirus/usa/South-Dakota'
    'New Hampshire'                = 'https://www.worldometers.info/coronavirus/usa/New-Hampshire'
    'West Virginia'                = 'https://www.worldometers.info/coronavirus/usa/West-Virginia'
    'North Dakota'                 = 'https://www.worldometers.info/coronavirus/usa/North-Dakota'
    'Maine'                        = 'https://www.worldometers.info/coronavirus/usa/Maine'
    'Montana'                      = 'https://www.worldometers.info/coronavirus/usa/Montana'
    'Wyoming'                      = 'https://www.worldometers.info/coronavirus/usa/Wyoming'
    'Alaska'                       = 'https://www.worldometers.info/coronavirus/usa/Alaska'
    'Hawaii'                       = 'https://www.worldometers.info/coronavirus/usa/Hawaii'
    'Vermont'                      = 'https://www.worldometers.info/coronavirus/usa/Vermont'
    'Northern Mariana Islands'     = 'https://www.worldometers.info/coronavirus/usa/Northern-Mariana-Islands'
    'Guam'                         = 'https://www.worldometers.info/coronavirus/usa/guam'
    'Puerto Rico'                  = 'https://www.worldometers.info/coronavirus/usa/puerto-rico'
    'United States Virgin Islands' = 'https://www.worldometers.info/coronavirus/usa/United-States-Virgin-Islands'
}

function Get-AllCharts() {
    $ret = @{}

    foreach ($key in $states.Keys) {
        $ret[$key] = Get-Charts -url $states[$key]
    }

    $ret
}

$usefulChartNames = [ordered]@{
    'Total Cases'  = 'coronavirus-cases-linear.Cases' # Total Cases
    'New Cases'    = 'graph-cases-daily.Daily Cases' # New Cases
    'Total Deaths' = 'coronavirus-deaths-linear.Deaths' # Total Deaths
    'New Deaths'   = 'graph-deaths-daily.Daily Deaths' # New Deaths
    'Active Cases' = 'graph-active-cases-total.Currently Infected' # Active Cases
}

function Get-DataByDay($charts, $day, $includeChartNames) {
    $data = @()
    foreach ($state in $charts.Keys) {
        $stateData = [PSCustomObject]@{
            State = $state
        }
        foreach ($chartName in $includeChartNames.Keys) {
            Add-Member -InputObject $stateData -Name $chartName -Value $charts[$state][$includeChartNames[$chartName]][$day] -MemberType NoteProperty
        }
        $data += [pscustomobject]$stateData
    }
    return $data
}