// Dashboard Date Filter Logic
document.addEventListener('DOMContentLoaded', function () {
    var startDateInput = document.getElementById('start_date');
    var endDateInput = document.getElementById('end_date');

    if (!startDateInput || !endDateInput) return;

    function addDays(date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    }

    function formatDate(date) {
        var year = date.getFullYear();
        var month = (date.getMonth() + 1).toString().padStart(2, '0');
        var day = date.getDate().toString().padStart(2, '0');
        return year + '-' + month + '-' + day;
    }

    function updateConstraints() {
        var startVal = startDateInput.value ? new Date(startDateInput.value) : null;
        var endVal = endDateInput.value ? new Date(endDateInput.value) : null;

        if (startVal) {
            endDateInput.min = formatDate(startVal);
            endDateInput.max = formatDate(addDays(startVal, 365));
        }

        if (endVal) {
            startDateInput.max = formatDate(endVal);
            startDateInput.min = formatDate(addDays(endVal, -365));
        }
    }

    startDateInput.addEventListener('change', updateConstraints);
    endDateInput.addEventListener('change', updateConstraints);
    updateConstraints();
});

// Chart Initialization Helper
window.initDashboardChart = function(canvasId, labels, data, colors) {
    var ctx = document.getElementById(canvasId).getContext('2d');
    const chart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                data: data,
                backgroundColor: colors,
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'right',
                    labels: {
                        boxWidth: 10,
                        font: {size: 10}
                    }
                },
                datalabels: {
                    color: '#fff',
                    font: {
                        weight: 'bold',
                        size: 11
                    },
                    formatter: function(value) {
                        return value;
                    }
                }
            }
        },
        plugins: [ChartDataLabels]
    });

    chart.reset();   // 차트 요소를 초기 위치(각도 0)로 리셋
    chart.update();  // 다시 애니메이션과 함께 그림
};
