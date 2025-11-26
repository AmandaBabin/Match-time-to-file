library(tidyverse)
library(lubridate)
library(data.table)
library(here)

audio_list <- paste0(r"(\\142.2.83.52\whalenas1\MOORED_PAM_DATA\2015\05\MGL_2015_05\AMAR143.1.8000.M8Q-51)") # copy the path to .wav files into the r"()"

audio_data <-list.files(audio_list, pattern = ".wav")

audio <- audio_data %>%
  as_tibble_col(column_name = "Filename") %>%
  mutate(datestring = str_extract(Filename, "\\d{8}\\w\\d{6}\\w")) %>% # this pulls out specifically our YYYYMMDDTHHMMSSZ timestamp - modify regex as needed
  mutate(filedate = as_datetime(datestring, format="%Y%m%dT%H%M%SZ")) #reformat as needed

data <- read_csv(r"(D:\BW Aud files for characterization\Team Whale BW Aud files\MGL_2015_05\MGL_2015_05_datetimes.csv)",locale=locale(encoding="latin1"))

datetime_list<-data %>%
  mutate(date_format = as_date(Date, format="%m/%d/%y")) %>% 
  mutate(datetime_format = as_datetime(as.character(paste(date_format, Time)))) %>% 
  filter(`Deployment`=="MGL_2015_05") %>%  #change to match wav folder
  rowwise() %>% #This and the following three lines are the important lines to datetime match from a csv with the filename formatting on the NAS
  mutate(Filename = audio$Filename[max(which(audio$filedate <= datetime_format))]) %>% 
  ungroup()

filename_list <- list(
      datetime_list)

filename_output <- rbindlist(filename_list)
output_file = paste0("Filenames.csv")
write_csv(filename_output, here(output_file))
