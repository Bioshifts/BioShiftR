## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  message = F,
  comment = "#>"
)

## ----setup, echo=TRUE, message=FALSE, warning=FALSE---------------------------
library(BioShiftR)
library(dplyr)
library(ggplot2)
theme_set(theme_bw())

## ----eval=FALSE, echo=TRUE, message=FALSE, warning=FALSE----------------------
# # this vignette also uses the following packages for data visualization
# # downstream of BioShiftR functions. They will need to be installed
# # in order to run code from this vignette.
# require(ggallin)
# require(rnaturalearth)
# require(ggridges)
# require(ggthemes)
# require(plotrix)
# require(patchwork)

## -----------------------------------------------------------------------------

library(BioShiftR)
library(dplyr)

# get shifts
shifts <- get_shifts(type = "ELE",
                 group = "Terrestrial Invertebrates")


## ----class.source = "fold-hide"-----------------------------------------------

# plot a histogram
p1 <- shifts %>% 
  
  ggplot(aes(x = calc_rate)) +
  # add histogram
  geom_histogram(fill = "purple", 
                 center = 0,
                 color = "black", 
                 linewidth = .2) +
  
  # add line at zero
  geom_vline(xintercept = 0) +
  
  # transform x axis
  scale_x_continuous(trans = ggallin::ssqrt_trans) +
  
  # labels
  labs(x = "Range Shift Rate (m/year)",
       y = "Count",
       title = "Elevation shift rates for terrestrial invertebrates") + 
  
  # theme
  ggthemes::theme_few(base_size = 10) +
  theme(plot.title.position = "plot") +
  
  # coords
  coord_cartesian(xlim = c(-100, 100),
                  ylim = c(-4, 440),
                  expand = F) +
  
  # annotate n
  annotate(geom = "text",
           x = 90,
           y = 420,
           label = paste0("n = ",scales::comma(nrow(shifts))),
           hjust = 1.2, 
           vjust = 1.2,
           size = 2.5)

# view p1:
# p1


## ----echo=F,  fig.width=6, fig.height=3, out.width="70%"----------------------
p1

## -----------------------------------------------------------------------------
# add polygon info
shifts2 <- shifts %>%
  # add info for study area polygons (type "SA")
  add_poly_info(type = "SA") 

## -----------------------------------------------------------------------------

# make map ----------------------------------------------------------------
p2 <- shifts2 %>% 
  
  # summarize shifts by article and polygon ID
  group_by(article_id, poly_id, lat_cent_deg, lon_cent_deg) %>%
  summarize(lat_cent_deg = unique(lat_cent_deg),
            lon_cent_deg = unique(lon_cent_deg),
            n = n()) %>%
  arrange(desc(n)) %>%
  
  # plot
  ggplot() + 
  
  # add world geometries
  geom_sf(data = rnaturalearth::ne_countries(returnclass = "sf"),
          fill = "grey82", color = "transparent") +
  
  # add points
  geom_point(aes(x = lon_cent_deg,
                 y = lat_cent_deg,
                 size = n),
  fill = "purple",
  shape = 21,
  stroke = .2, 
  alpha = .6) +
  
  # scale size
  scale_size_area(breaks = c(10,100,300),
                  max_size = 12) +
  
  # theme
  ggthemes::theme_few(base_size = 10) +
  theme(legend.position = "right",
        plot.title.position = "plot",
        legend.justification = c(.5,.5),
        legend.box.background = element_blank(),
        legend.background = element_blank(),
        plot.margin = margin(0,0,0,l=0),
        legend.box = "horizontal") +
  
  coord_sf(expand = F) +
  
  # labs
  labs(x = NULL, 
       y = NULL,
       fill = "Avg. shift\nrate\n(km/yr)",
       size = "n in\ngroup",
       title = "Location of elevation shift estimates") 

# view p2:
# p2



## ----echo=F,  fig.width=6, fig.height=3, out.width="80%"----------------------
p2

## -----------------------------------------------------------------------------
# add methods to shifts database
shifts3 <- shifts2 %>%
  # add methodological variables
  add_methods()

## -----------------------------------------------------------------------------

# ridgeplot of study durations by parameter
p3.1 <- shifts3 %>%
  
  # change parameter names and order
  mutate(param2 = recode(param, 
                         "LE" = "Leading\nEdges",
                         "TE" = "Trailing\nEdges",
                         "O" = "Centres")) %>%
  mutate(param2 = factor(param2, levels = c("Trailing\nEdges","Centres","Leading\nEdges"))) %>%
  
  # plot
  ggplot(aes(x = duration, 
             y = param2)) +
  
  # add density ridges
  ggridges::geom_density_ridges2(fill = "purple", alpha = .9) +
  
  # axes
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  
  # theme stuff
  ggthemes::theme_few(base_size = 10) +
  
  # labs
  labs(y = NULL,
       x = "Study Duration") +
  coord_cartesian(clip = "off") 


# bar plot of observation types
p3.2 <- shifts3 %>%
  
  # plot
  ggplot(aes(x = obs_type)) +
  
  # add bars
  geom_bar(width = .7,
           fill = "purple",
           color = "black") +
  
  # coords
  coord_cartesian(xlim = c(.5, 2.5),
                  ylim = c(0, 1590),
                  expand = F) +
  
  # theme stuff
  ggthemes::theme_few(base_size = 10) +
  
  # labs
  scale_x_discrete(labels = c("Abundance","Occurrence")) +
  labs(y = "Count",
       x = "Observation Type") 


library(patchwork)

p3 <- ((
    (p3.1 + theme(plot.margin = margin(r=2))) | (p3.2 + theme(plot.margin = margin(l = 2)))))+
    plot_annotation( title = 'Distribution of selected methods') 

# view p3:
# p3



## ----echo=FALSE, fig.width=6, fig.height=3, out.width="70%"-------------------
p3

## -----------------------------------------------------------------------------
# add methods to shifts database
shifts4 <- shifts3 %>%
  # add warming trends for study areas
  # `type = "SP"` would add species-level warming trends, but not every 
  # species has total range areas available, so we'll use study-level trends
  # to minimize NAs in the already-limited dataset
  add_trends(type = "SA")
  

## -----------------------------------------------------------------------------

# model shifts as independent 
mod_all <- lm(data = shifts4,
              formula = calc_rate ~ trend_temp_mean)
# pull trend and p_val
mod_all_annotation <- 
  paste0("Estimate: ", round(summary(mod_all)$coefficients["trend_temp_mean","Estimate"], 2), "\n",
         "p ", ifelse(summary(mod_all)$coefficients["trend_temp_mean","Pr(>|t|)"] < .05, "< 0.05", round(summary(mod_all)$coefficients["trend_temp_mean","Pr(>|t|)"], 2)))
# augment model
mod_all_au <- broom::augment(mod_all, interval = "confidence")

# plot
p4.1 <- mod_all_au %>%
  
  # plot
    ggplot(aes(x = trend_temp_mean, 
               y = calc_rate)) +
  
  # add x and y lines at 0
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 0) +
  
  # add raw points
    geom_point(alpha = .3,
               color = "purple",
               shape = 16,
               size = 1) +
  
  # add confidence interval
    geom_ribbon(aes(ymin = .lower, 
                    ymax = .upper),
                fill = "purple", alpha = .7) +
  
  # add fitted line
    geom_line(aes(y = .fitted)) +
    
  # labs
    labs(x = "Warming Rate (°C/year)",
         y = "Shift Rate\n(m/year)",
         title = "Individual species' shifts") +
    
  # theme
    ggthemes::theme_few(base_size = 10) +
    theme(plot.title.position = "plot") +
  
  # add annotation
  annotate(geom = "label",
           x = max(shifts4$trend_temp_mean),
           y = min(shifts4$calc_rate),
           label = mod_all_annotation,
           hjust = 1,
           vjust = 0)


# summarize by study ID, polygon ID, and timeframe of sampling
shifts4_means <- shifts4 %>%
    # group by article ID and polygon ID (polygons are within articles)
    group_by(article_id, poly_id, midpoint_firstperiod, midpoint_lastperiod) %>%
    # find mean rates
    summarize(
        se_calc_rate = plotrix::std.error(calc_rate),
        se_trend = plotrix::std.error(trend_temp_mean),
        calc_rate = mean(calc_rate, na.rm= T),
        trend_temp_mean = mean(trend_temp_mean, na.rm=T),,
        n = n()) 


# plot mean data and basic model fit
mod_means <- lm(data = shifts4_means,
              formula = calc_rate ~ trend_temp_mean,
              weights = sqrt(n)) #sqrt the weights to normalize them a bit
mod_means_annotation <- 
  paste0("Estimate: ", round(summary(mod_means)$coefficients["trend_temp_mean","Estimate"], 2), "\n",
         "p ", ifelse(summary(mod_means)$coefficients["trend_temp_mean","Pr(>|t|)"] < .05, "< 0.05", round(summary(mod_means)$coefficients["trend_temp_mean","Pr(>|t|)"], 2)))
mod_means_au <- broom::augment(mod_means, shifts4_means, interval = "confidence")

# plot
p4.2 <- mod_means_au %>% 
  
  # start plot
    ggplot(aes(x = trend_temp_mean,
               y = calc_rate)) +
  
  # add x and y lines at 0
    geom_hline(yintercept = 0) +
    geom_vline(xintercept = 0) +
    
    # add raw data
    geom_errorbar(aes(xmin = trend_temp_mean - se_trend,
                      xmax = trend_temp_mean + se_trend),
                  linewidth = .2) +
    geom_errorbar(aes(ymin = calc_rate - se_calc_rate,
                      ymax = calc_rate + se_calc_rate),
                  linewidth = .2) +
    geom_point(alpha = .9,
               fill = "purple",
               shape = 21,
              # size = 2,
               aes(size = n)
              ) +

    
    # add confidence interval
    geom_ribbon(aes(ymin = .lower, 
                    ymax = .upper),
                fill = "purple", alpha = .7) +
  # add fitted line
    geom_line(data = mod_means_au,
              aes(y = .fitted)) +
    
  # scale point size
    scale_size_area(breaks = c(10,100,300),
                    max_size = 7) +
    
    # labels
    labs(x = "Warming Rate (°C/year)",
         y = "Shift Rate\n(m/year)",
         title = "Group level means",
         size = "n in group") +
    
  # theme
    ggthemes::theme_few(base_size = 10) +
    theme(plot.title.position = "plot",
          legend.position = "inside",
          legend.position.inside = c(.005, .995),
          legend.justification = c(0,1),
          legend.direction = "horizontal",
          legend.title.position = "top",
          legend.background = element_rect(color = "black"),
          legend.text.position = "bottom") +
  
    # add annotation
  annotate(geom = "label",
           x = max(shifts4_means$trend_temp_mean),
           y = min(shifts4_means$calc_rate - shifts4_means$se_calc_rate, na.rm=T),
           label = mod_means_annotation,
           hjust = 1,
           vjust = 0)
    


# merge plots
p4 <- ((
    (p4.1 + theme(plot.margin = margin(r=2))) | (p4.2 + theme(plot.margin = margin(l = 2)))))


# view p4:
# p4


## ----echo=FALSE, fig.width=6, fig.height=3, out.width="80%"-------------------
p4

