(function() {
  const removeBlankOptions = function() {
    const categorySelect = document.getElementById('issue_category_id');
    if (categorySelect) {
      const blankOption = categorySelect.querySelector('option[value=""]');
      if (blankOption) blankOption.remove();
    }

    const assignedToSelect = document.getElementById('issue_assigned_to_id');
    if (assignedToSelect) {
      const blankOption = assignedToSelect.querySelector('option[value=""]');
      if (blankOption) blankOption.remove();
    }
  };

  const init = function() {
    removeBlankOptions();

    // Redmine 일감 폼은 AJAX로 업데이트되므로 DOM 변화를 감지합니다.
    const form = document.getElementById('issue-form');
    if (form) {
      const observer = new MutationObserver(function(mutations) {
        removeBlankOptions();
      });
      observer.observe(form, { childList: true, subtree: true });
    }
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
