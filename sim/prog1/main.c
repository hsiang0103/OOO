// MergeSort implementation (stable, O(n log n)) replacing previous BubbleSort.
static void merge(int *arr, int left, int mid, int right, int *temp) {
    int i = left;      // pointer into left half
    int j = mid + 1;   // pointer into right half
    int k = left;      // pointer into temp

    while (i <= mid && j <= right) {
        if (arr[i] <= arr[j]) {
            temp[k++] = arr[i++];
        } else {
            temp[k++] = arr[j++];
        }
    }
    while (i <= mid) temp[k++] = arr[i++];
    while (j <= right) temp[k++] = arr[j++];

    for (int p = left; p <= right; ++p) {
        arr[p] = temp[p];
    }
}

static void merge_sort_recursive(int *arr, int left, int right, int *temp) {
    if (left >= right) return;
    int mid = left + (right - left) / 2;
    merge_sort_recursive(arr, left, mid, temp);
    merge_sort_recursive(arr, mid + 1, right, temp);
    // Optimization: only merge if needed
    if (arr[mid] > arr[mid + 1]) {
        merge(arr, left, mid, right, temp);
    }
}

void MergeSort(int *arr, int size) {
    if (size <= 1) return;
    // Use a Variable Length Array for temp buffer (C99). If environment
    // disallows VLAs, replace with static max-size buffer or iterative bottom-up version.
    int temp[size];
    merge_sort_recursive(arr, 0, size - 1, temp);
}

int main(void) {
    extern int array_size;
    extern int array_addr;
    extern int _test_start;

    MergeSort(&array_addr, array_size);

    for (int i = 0; i < array_size ; i++){
        *((&_test_start)+i)=*((&array_addr)+i);
    }

    return 0;
}
