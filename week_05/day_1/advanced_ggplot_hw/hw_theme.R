
hw_theme <- list(
  
  theme(panel.background = element_rect(fill = "white"),
        panel.border = element_rect(fill = NA, colour = "gray75"),
        panel.grid.major.y = element_line(colour = "gray75"),
        axis.text = element_text(size = 10, face = "bold"),
        axis.title = element_text(size = 10, face = "bold"),
        text = element_text(size = 12),
        title = element_text(size = 14),
        legend.title = element_text(size = 12),
        legend.key = element_rect(fill = NA)),
  scale_colour_manual(values = col_scheme),
  scale_fill_manual(values = col_scheme)
  
)
  