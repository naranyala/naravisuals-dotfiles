#include <stdio.h>
#include <time.h> // Include the standard C time header file

#define TIME_STR_LEN 100

int main() {
  // 1. Get the raw time value (current calendar time)
  // time_t is a type usually representing the number of seconds since the Epoch
  // (Jan 1, 1970).
  time_t raw_time;

  // Call time() with a NULL pointer to get the current time.
  raw_time = time(NULL);

  printf("Raw time (seconds since Epoch): %ld\n", (long)raw_time);

  // 2. Convert the raw time into a local time structure
  // localtime() converts time_t into a struct tm (broken-down time)
  struct tm *local_info;

  // The struct tm holds components like year, month, day, hour, minute, second.
  local_info = localtime(&raw_time);

  // 3. Format the time structure into a human-readable string
  char time_string[TIME_STR_LEN];

  // strftime formats the struct tm data into a string buffer according to the
  // given format specifiers. %A: Full weekday name, %B: Full month name, %d:
  // Day of the month, %Y: Year with century, %H: Hour (00-23), %M: Minute
  // (00-59), %S: Second (00-59)
  size_t length =
      strftime(time_string,  // Destination buffer
               TIME_STR_LEN, // Maximum size of buffer
               "Current Time: %A, %B %d, %Y - %H:%M:%S", // Format string
               local_info // Source time structure
      );

  // Check if formatting was successful
  if (length > 0) {
    printf("Formatted Time String: %s\n", time_string);
  } else {
    fprintf(stderr, "Error: strftime failed to format the time.\n");
  }

  return 0;
}
