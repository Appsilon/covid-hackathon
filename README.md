# covid-hackathon

# Getting the data

1. We need to follow this guide: https://docs.google.com/spreadsheets/d/1QKGeBeeOW7gANOkrLFXreY7YBBfIQOzOuFtE4i_Peig/edit#gid=77924852

```
pip install awscli
aws configure --profile safegraph

aws s3 sync s3://safegraph-outgoing/hackathon/nyc_v2/y=2019/m=12/d=01/ ./mylocaldirectory/ --profile safegraph
```

# Reading data from R

`devtools::install_github("apache/arrow/r")`

