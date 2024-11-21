package helloworld;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@SpringBootApplication
public class HelloWorldApplication {

    public static void main(String[] args) {
        SpringApplication.run(HelloWorldApplication.class, args);
    }

    @Controller
    class IndexController {

        @GetMapping("/")
        public String index(Model model) {
            // Get the current date
            LocalDate currentDate = LocalDate.now();

            // Format the date as "Month Day, Year" (e.g., "November 21, 2024")
            String formattedDate = currentDate.format(DateTimeFormatter.ofPattern("MMMM dd, yyyy"));

            model.addAttribute("title", "Hello, World!");
            model.addAttribute("date", formattedDate);
            return "index";
        }
    }
}
