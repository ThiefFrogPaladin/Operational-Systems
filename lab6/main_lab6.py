import time
import random
import matplotlib.pyplot as plt
from tabulate import tabulate
from array import array
import sys


def generate_random_array(size, min_value=1, max_value=1000):
    return [random.randint(min_value, max_value) for _ in range(size)]


def remove_even_numbers(arr):
    result = []
    for num in arr:
        if num % 2 != 0:
            result.append(num)
    return result


def measure_time_for_size(size):
    test_array = generate_random_array(size)

    start_time = time.perf_counter()
    result = remove_even_numbers(test_array)
    end_time = time.perf_counter()

    execution_time = end_time - start_time
    return execution_time, len(test_array), len(result)


def run_benchmark():
    sizes = [100, 1000, 10000, 100000, 500000, 1000000]
    results = []

    print("Начало измерения времени работы алгоритма удаления четных чисел")
    print("-" * 60)

    for size in sizes:
        try:
            exec_time, original_size, result_size = measure_time_for_size(size)
            results.append([size, original_size, result_size, f"{exec_time:.6f}"])
            print(f"Размер: {size:7d} | Время: {exec_time:.6f} сек | "
                  f"Удалено четных: {original_size - result_size}")
        except MemoryError:
            print(f"Размер: {size:7d} | Ошибка: недостаточно памяти")
            results.append([size, size, "Ошибка", "MemoryError"])
            break

    return results


def display_results_table(results):
    headers = ["Размер массива", "Исходный размер", "Размер после удаления", "Время (сек)"]
    print("\n" + "=" * 80)
    print("РЕЗУЛЬТАТЫ ИЗМЕРЕНИЙ")
    print("=" * 80)
    print(tabulate(results, headers=headers, tablefmt="grid"))
    print("=" * 80)


def plot_results(results):
    sizes = [r[0] for r in results if r[3] != "MemoryError"]
    times = [float(r[3]) for r in results if r[3] != "MemoryError"]

    plt.figure(figsize=(10, 6))
    plt.plot(sizes, times, 'bo-', linewidth=2, markersize=8)
    plt.xlabel('Размер массива')
    plt.ylabel('Время выполнения (секунды)')
    plt.title('Зависимость времени удаления четных чисел от размера массива')
    plt.grid(True, alpha=0.3)
    plt.xscale('log')
    plt.yscale('log')

    for i, (size, time) in enumerate(zip(sizes, times)):
        plt.annotate(f'{size}', (size, time), textcoords="offset points",
                     xytext=(0, 10), ha='center')

    plt.tight_layout()
    plt.savefig('benchmark_results.png', dpi=150)
    plt.show()


def main():
    print("Лабораторная работа: Алгоритм удаления четных чисел")
    print("Вариант: 3. Буквы Фамилии в кодировке UTF-8 были сложены с последующим нахождением остатком от 8")
    print("Состав бригады: Васильев П.А.")
    print("Используемая структура данных: ArrayList (список Python)")
    print()

    results = run_benchmark()
    display_results_table(results)

    try:
        plot_results(results)
        print("\nГрафик сохранен в файл 'benchmark_results.png'")
    except Exception as e:
        print(f"\nНе удалось построить график: {e}")




if __name__ == "__main__":
    main()