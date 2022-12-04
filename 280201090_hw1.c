
#include <stdio.h>
#include <stdlib.h>

// ID: 280201090

typedef struct dynamic_array {
	int capacity;
	int size;
	void** elements;
} dynamic_array;

void init_array(dynamic_array* array) {
	(*array).capacity = 2;
	(*array).size = 0;
	(*array).elements = (void**)malloc(2 * sizeof(void*));
	(*array).elements[0] = (void*)malloc(sizeof(void));
	(*array).elements[1] = (void*)malloc(sizeof(void));
	(*array).elements[0] = NULL;
	(*array).elements[1] = NULL;
}
void put_element(dynamic_array* array, void* element) {
	if ((*array).size == (*array).capacity) {
		int old_size = (*array).capacity;
		int new_size = 2 * old_size;
		void** new_elements = (void**)malloc(new_size * sizeof(void*));
		int i;
		for (i = 0; i < old_size;i++) {
			new_elements[i] = (*array).elements[i]; 
		}
		for (; i < new_size; i++) {
			new_elements[i] = (void*)malloc(sizeof(void));
			new_elements[i] = NULL;
		}
		(*array).elements = new_elements;
		(*array).capacity = new_size;
	}
	int i = (*array).size;
	(*array).elements[(*array).size] = element;
	(*array).size += 1;
}
void remove_element(dynamic_array* array, int position) {
	int i = position + 1;
	for (; i < array->size; i++) {
		array->elements[i - 1] = array->elements[i];
	}
	free(array->elements[i]);
	array->size -= 1;

	//Does size reduce to capacity/2 ? 
	if (array->size <= (array->capacity)/2) {
		int old_capacity = array->capacity;
		int new_capacity = old_capacity / 2;
		void** new_elements = (void**)malloc(new_capacity * sizeof(void*));
		int i = 0;
		for (; i < new_capacity; i++) {
			new_elements[i] = array->elements[i];
		}
		for (; i < old_capacity; i++) {
			free((*array).elements[i]);
		}
		(*array).elements = new_elements;
		(*array).capacity = new_capacity;
	}
}
void* get_element(dynamic_array* array, int position) {
	void* result = array->elements[position];
	return result;
}

//Checking string equality
int is_string_equal(char* string_1, char* string_2) {
	int i = 0;
	while (string_1[i] != '\0' && string_2[i] != '\0') {
		if (string_1[i] != string_2[i]) 
			return 0; 
		i++;
	}
	if (string_1[i] == '\0' && string_2[i] == '\0') 
		return 1;

	return 0;
}

typedef struct song {
	char* name;
	float duration;
} song;

int main() {
	dynamic_array array;
	init_array(&array);

	int inquiry = 0;
	while (inquiry != 4) {
		printf("\nPlease select one of the number given below: \n");
		printf("1 - Add a song\n");
		printf("2 - Delete a song\n");
		printf("3 - List all songs\n");
		printf("4 - Exit\n");

		scanf("%d", &inquiry);

		if (inquiry == 1) {
			void* ptr = malloc(sizeof(song));
			struct song* song_addr = (song*)ptr;
			song_addr->name = (char*)malloc(64 * sizeof(char));
			float duration;

			printf("\nName of the song:");
			scanf("%s", song_addr->name);
			printf("Interval of the song:");
			scanf("%f", &duration);
			song_addr->duration = duration;

			put_element(&array, song_addr);
		}
		else if (inquiry == 2) {
			if (array.size > 0) {
				char* nameDeleted = (char*)malloc(64 * sizeof(char));
				printf("\nName of the song to delete:");
				scanf("%s", nameDeleted);
				int position;
				int is_found = 0;
				for (int i = 0; i < array.size; i++) {
					song* elementAt = (song*)get_element(&array, i);
					if (is_string_equal(elementAt->name, nameDeleted)) {
						position = i;
						free(elementAt->name);
						free(nameDeleted);
						is_found = 1;
						break;
					}
				}
				if (is_found) {
					remove_element(&array, position);
				}
				else {
					printf("There is no such a music!\n");
				}
			}
			else {
				printf("Your song list is empty!\n");
			}
		}
		else if (inquiry == 3) {
			printf("\n------SONG LIST------\n");
			if (array.size == 0)
				printf("Nothing to show here :(\n");
			else {
				for (int i = 0; i < array.size; i++) {
					song* current_song = (song*)get_element(&array, i);
					printf("Song Name: %s - Song Duration: %f\n", current_song->name, current_song->duration);
				}
			}
		}
		else {
			if(inquiry != 4)
				printf("\nWe have no such an option :(\n");
			else {
				for (int i = 0; i < array.size; i++) {
					song* elementAt = (song*)get_element(&array, i);
					free(elementAt->name);
					free(elementAt);
				}
				free(array.elements);
			}
		}
	}
	return 0;
}