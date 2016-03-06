#神戸市大気汚染常時監視結果の一時間測定データのCSVを読み込んで
#elasticsearchのbulk APIで読み込める形式にする関数
#エラー処理はまったくしていないので注意
function read_air($importFilePath , $resultFilePath, $term , $id){ 
    $esCmd = @{ index = @{ _index = "air"; _type = "" ; _id = "" } } #elasticserchコマンド用のオブジェクトを格納する変数
    $count = 0
    $result = "" #出力を格納する変数
    $delim = ""　


    $csv = Import-Csv $importFilePath | Where-Object { $_.'測定項目名称' -like $term} 
    $csv | ForEach-Object {
        $esCmd.index._type = $_.'測定項目名称';
        $esCmd.index._id = $id + $count++;
        $result = $result + $delim + ($esCmd | ConvertTo-Json -Compress);
        $delim = "`n"

        #elasticsearchで使いやすいように年月日時を一つの項目にまとめる
        $_ | Add-Member TimeStamp ($_."年" +  $_."月"  + $_."日" + "-" +  $_."時");

        #括弧やスラッシュがあるとelasticsearchで読み込んだ時の挙動がおかしいのでアンダーバーに置換
        $_.'測定項目名称' = $_.'測定項目名称' -replace '[\(\)\/]','_' 
        $result = $result + $delim +($_ | ConvertTo-Json -Compress); 
     } 
    $result | out-file -filepath $resultFilePath  -encoding UTF8 -Append;
}

#read_air  "C:\work\data\2012_0103_hour.csv" "C:\work\data\test.json" "*ppm*" "2012"
#read_air  "C:\work\data\2013_0103_hour.csv" "C:\work\data\test.json" "*ppm*" "2013"
#read_air  "C:\work\data\2014_0103_hour.csv" "C:\work\data\test.json" "*ppm*" "2014"
#read_air  "C:\work\data\2015_0103_hour.csv" "C:\work\data\test.json" "*ppm*" "2015"

#read_air  "C:\work\data\2012_0103_hour.csv" "C:\work\data\test.json" "pm2.5*" "20121"
#read_air  "C:\work\data\2013_0103_hour.csv" "C:\work\data\test.json" "pm2.5*" "20131"
#read_air  "C:\work\data\2014_0103_hour.csv" "C:\work\data\test.json" "pm2.5*" "20141"
read_air  "C:\work\data\2015_0103_hour.csv" "C:\work\data\test1.json" "pm2.5*" "20151"
