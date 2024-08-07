library(plotly)
library(dplyr)
library(ggsankey)


data_creator <- function(csv, color_id, split = FALSE) {
  a <- mutate(csv, Intro.Com = 1, Law = Signed.by.Gov)
  normal_a <- a %>% filter(is.na(Amended.2) | Amended.2 == 0) %>% 
    filter(is.na(Returned) | Returned == 0) 
  
  # Separate all the data with the initial return
  one_a <- a %>% filter(Amended.2 == 1, Returned == 0)
  
  # Separate all the data with the second return
  two_a <- a %>% filter(Amended.2 == 0, Returned == 1)
  
  # Separate all the data with both returns
  both_a <- a %>% filter(Amended.2 == 1, Returned == 1)
  
  # Now to turn the data into something that can be read by the ggsankey
  normal_df <- normal_a %>% 
    make_long(Intro.Com,
              Pass.Com.1,
              Pass.Floor.1,
              Pass.Com.2,
              Pass.Floor.2,
              To.Gov,
              Signed.by.Gov,
              Law) %>% 
    na_if(0) %>% 
    filter(!is.na(node)) 
  
  one_df <- rbind(
    make_long(one_a,
              Intro.Com,
              Pass.Com.1,
              Pass.Floor.1,
              Pass.Com.2,
              Pass.Floor.2) %>% filter(!is.na(next_node)),
    make_long(one_a,
              Pass.Floor.2,
              Pass.Floor.1,
              To.Gov,
              Signed.by.Gov,
              Law)) %>% 
    na_if(0) %>% 
    filter(!is.na(node)) 
  two_df <- NULL
  both_df <- NULL
 if (split) {
  two_df <- rbind(
    make_long(two_a,
              Intro.Com,
              Pass.Com.1,
              Pass.Floor.1,
              Pass.Com.2,
              Pass.Floor.2, 
              To.Gov) %>% filter(!is.na(next_node)),
    make_long(two_a,
              To.Gov,
              Pass.Floor.1,
              Signed.by.Gov),
    make_long(two_a,
              To.Gov,
              Pass.Floor.2,
              Signed.by.Gov,
              Law)) %>% 
    na_if(0) %>% 
    filter(!is.na(node)) 
  
  both_df <- rbind(
    make_long(both_a,
              Intro.Com,
              Pass.Com.1,
              Pass.Floor.1,
              Pass.Com.2,
              Pass.Floor.2) %>% filter(!is.na(next_node)),
    make_long(both_a,
              Pass.Floor.2,
              Pass.Floor.1,
              To.Gov) %>% filter(!is.na(next_node)),
    make_long(both_a,
              To.Gov,
              Pass.Floor.1,
              Signed.by.Gov) %>% filter(!is.na(next_node)),
    make_long(both_a,
              To.Gov,
              Pass.Floor.2,
              Signed.by.Gov,
              Law) %>% filter(!is.na(next_node))
  )
 } else {
  two_df <- rbind(
    make_long(two_a,
              Intro.Com,
              Pass.Com.1,
              Pass.Floor.1,
              Pass.Com.2,
              Pass.Floor.2, 
              To.Gov) %>% filter(!is.na(next_node)),
    make_long(two_a,
              To.Gov,
              Pass.Floor.1,
              Pass.Floor.2,
              Signed.by.Gov,
              Law)
    ) %>% 
    na_if(0) %>% 
    filter(!is.na(node)) 
  
  both_df <- rbind(
    make_long(both_a,
              Intro.Com,
              Pass.Com.1,
              Pass.Floor.1,
              Pass.Com.2,
              Pass.Floor.2) %>% filter(!is.na(next_node)),
    make_long(both_a,
              Pass.Floor.2,
              Pass.Floor.1,
              To.Gov) %>% filter(!is.na(next_node)),
    make_long(both_a,
              To.Gov,
              Pass.Floor.1,
              Pass.Floor.2,
              Signed.by.Gov,
              Law) %>% filter(!is.na(next_node))
  )
 
 }
  
  total_df <- rbind(normal_df, one_df, two_df)
  label <- levels(total_df$x)
  new_total_df <- total_df %>% select(x, next_x) %>% group_by(x, next_x) %>% summarize(n = n()) %>% 
    filter(!is.na(next_x)) %>% 
    mutate(color = color_id)
  return(new_total_df)
  
}

sierra_data <- function(csv, split = FALSE) {
  supported <- filter(csv, SC.Position == 1)
  neutral <- filter(csv, SC.Position == 0)
  opposed <- filter(csv, SC.Position == -1)
  supported_df <- data_creator(supported, "rgba(154,205,50,1.0)", split)
  neutral_df <- data_creator(neutral, "rgba(176,224,230,1.0)", split)
  opposed_df <- data_creator(opposed, "rgba(255,69,0,1.0)", split)
  return(rbind(supported_df, neutral_df, opposed_df))
}


# For legacy sake, this will work with data of type a
data_creator_a <- function(csv, color_id) {
  a <- mutate(csv, Intro.Com = 1)
  normal_a <- a %>% filter(is.na(Returned) | Returned == 0) %>% 
    filter(is.na(Returned.1) | Returned.1 == 0) 
  normal_a[,c("Returned", "Returned.1")]
  normal_a[,"Amd.Sub"]
  
  # Separate all the data with the initial return
  one_a <- a %>% filter(Returned == 1, Returned.1 == 0)
  
  # Separate all the data with the second return
  two_a <- a %>% filter(Returned == 0, Returned.1 == 1)
  
  # Separate all the data with both returns
  both_a <- a %>% filter(Returned == 1, Returned.1 == 1)
  
  # Now to turn the data into something that can be read by the ggsankey
  normal_df <- normal_a %>% 
    make_long(Intro.Com,
              Pass.Com,
              Pass.Floor,
              Pass.Com.1,
              Passed.Floor.2,
              To.Gov,
              Signed.by.Gov) %>% 
    na_if(0) %>% 
    filter(!is.na(node)) 
  
  one_df <- rbind(
    make_long(one_a,
              Intro.Com,
              Pass.Com,
              Pass.Floor,
              Pass.Com.1,
              Passed.Floor.2) %>% filter(!is.na(next_node)),
    make_long(one_a,
              Passed.Floor.2,
              Pass.Floor,
              To.Gov,
              Signed.by.Gov)) %>% 
    na_if(0) %>% 
    filter(!is.na(node)) 
  
  two_df <- rbind(
    make_long(two_a,
              Intro.Com,
              Pass.Com,
              Pass.Floor,
              Pass.Com.1,
              Passed.Floor.2, 
              To.Gov) %>% filter(!is.na(next_node)),
    make_long(two_a,
              To.Gov,
              Pass.Floor,
              #Passed.Floor.2,
              Signed.by.Gov),
    make_long(two_a,
              To.Gov,
              Passed.Floor.2,
              Signed.by.Gov)) %>% 
    na_if(0) %>% 
    filter(!is.na(node)) 
  
  both_df <- rbind(
    make_long(both_a,
              Intro.Com,
              Pass.Com,
              Pass.Floor,
              Pass.Com.1,
              Passed.Floor.2) %>% filter(!is.na(next_node)),
    make_long(both_a,
              Passed.Floor.2,
              Pass.Floor,
              To.Gov) %>% filter(!is.na(next_node)),
    make_long(both_a,
              To.Gov,
              Pass.Floor,
              Signed.by.Gov) %>% filter(!is.na(next_node)),
    make_long(both_a,
              To.Gov,
              Passed.Floor.2,
              Signed.by.Gov) %>% filter(!is.na(next_node))
  )
  
  total_df <- rbind(normal_df, one_df, two_df)
  label <- levels(total_df$x)
  new_total_df <- total_df %>% select(x, next_x) %>% group_by(x, next_x) %>% summarize(n = n()) %>% 
    filter(!is.na(next_x)) %>% 
    mutate(color = color_id)
  return(new_total_df)
  
}