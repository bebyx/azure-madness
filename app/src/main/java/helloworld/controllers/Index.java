package helloworld.controllers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Controller
class Index {

    @Value("${website.name}")
    private String websiteName;

    @GetMapping("/")
    public String index(Model model) {
        // Get the current date
        LocalDate currentDate = LocalDate.now();

        // Format the date as "Month Day, Year" (e.g., "November 21, 2024")
        String formattedDate = currentDate.format(DateTimeFormatter.ofPattern("MMMM dd, yyyy"));

        model.addAttribute("websiteName", websiteName);
        model.addAttribute("header", "Hello, World!");
        model.addAttribute("date", formattedDate);
        return "index";
    }
}